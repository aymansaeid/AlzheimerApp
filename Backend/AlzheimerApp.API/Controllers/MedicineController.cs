using AlzheimerApp.Application.DTOs.Medicines;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Manages the master medication schedules for Patients.
/// </summary>
/// <remarks>
/// **One medicine = one record, with all of its daily times in `scheduleTimes`.**
/// A pill taken at 08:00, 14:00 and 20:00 is ONE medicine with `scheduleTimes: ["08:00:00","14:00:00","20:00:00"]`,
/// and every daily dose log (`/api/MedicineLogs`) of it carries the same `medicineId`.
///
/// Strict Role-Based Access Control (RBAC) is enforced here. Patients can read their schedules,
/// but only the Care Team (Followers/Admins) can mutate (Create, Update, Delete) the schedules.
/// </remarks>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class MedicineController : ControllerBase
{
    private const string CareTeamRoles = $"{nameof(UserRole.Follower)},{nameof(UserRole.Admin)}";

    private readonly IMedicineService _medicineService;
    private readonly ILogger<MedicineController> _logger;

    public MedicineController(IMedicineService medicineService, ILogger<MedicineController> logger)
    {
        _medicineService = medicineService;
        _logger = logger;
    }

    /// <summary>
    /// Creates a medicine with all of its daily times in one request.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role. The creator is taken from the JWT
    /// token; do not send `creatorId`.
    ///
    /// **Fields:**
    /// * `scheduleTimes`: every time of day in **local (Turkey) time**, `HH:mm:ss`. At least 1, at most 12; duplicates are removed and the list is sorted.
    /// * `daysOfWeek`: comma-separated weekdays, 0 = Sunday … 6 = Saturday (7 is also accepted as Sunday). Example: `"1,3,5"`.
    /// * `startDate` / `endDate`: the course of treatment; `endDate` is optional (null = no end).
    ///
    /// Today's remaining doses are created immediately, so reminders work the same day.
    ///
    /// Sample request:
    ///
    ///     POST /api/Medicine
    ///     {
    ///        "patientId": "019ea1ef-4915-729d-b2cb-8d49f8b055ac",
    ///        "name": "Aspirin",
    ///        "dosage": "1 tablet",
    ///        "instructions": "Tok karnına",
    ///        "scheduleTimes": ["08:00:00", "14:00:00", "20:00:00"],
    ///        "daysOfWeek": "0,1,2,3,4,5,6",
    ///        "startDate": "2026-11-24T00:00:00Z",
    ///        "endDate": null
    ///     }
    /// </remarks>
    /// <response code="200">Created. Returns the medicine with its `id` and sorted `scheduleTimes`.</response>
    /// <response code="400">If validation fails (no name, no time, no day, endDate before startDate...).</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    [Authorize(Roles = CareTeamRoles)]
    [HttpPost]
    [ProducesResponseType(typeof(MedicineResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> AddMedicine([FromBody] MedicineRequest request)
    {
        if (!Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var creatorId))
            return Unauthorized(new { Error = "Invalid token claims." });

        return await Run(() => _medicineService.AddMedicineAsync(creatorId, request));
    }

    /// <summary>
    /// Retrieves all active medicines of a patient (one entry per medicine, with all its times).
    /// </summary>
    /// <remarks>
    /// **Flutter Note:** This returns the *Master Schedule* rules, not today's actual status.
    /// If you want to know if a patient actually took their pill today, use the `MedicineLogs` endpoints instead.
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <response code="200">Returns a list of active medications, sorted by name.</response>
    [HttpGet("patient/{patientId}")]
    [ProducesResponseType(typeof(List<MedicineResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetPatientMedicines(Guid patientId)
    {
        return await Run(() => _medicineService.GetPatientMedicinesAsync(patientId));
    }

    /// <summary>
    /// Retrieves a single medicine with all of its daily times.
    /// </summary>
    /// <remarks>
    /// **Flutter Note (edit screen):** a dose in the daily list (`/api/MedicineLogs/...`) has a `medicineId`.
    /// Call this with that id to load the medicine's full schedule (all `scheduleTimes`, days, dates) into the edit form.
    /// </remarks>
    /// <param name="id">The unique Guid of the Medicine.</param>
    /// <response code="200">Returns the medicine.</response>
    /// <response code="404">If the medicine does not exist.</response>
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(MedicineResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetMedicine(Guid id)
    {
        return await Run(() => _medicineService.GetMedicineAsync(id));
    }

    /// <summary>
    /// Updates a medicine: name, dosage, all daily times, days, dates or active flag. Send the full new state.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    ///
    /// To add or remove a time, send the complete new `scheduleTimes` list. Pending doses (today and later) that no
    /// longer match are removed, matching ones keep their id, and new times still ahead today are added.
    /// Taken/missed history is never changed. Set `isActive: false` to pause the medicine without deleting it.
    ///
    /// Sample request:
    ///
    ///     PUT /api/Medicine/01a1eaec-2db9-78ab-834f-4a4635f653ee
    ///     {
    ///        "name": "Aspirin",
    ///        "dosage": "1 tablet",
    ///        "instructions": "Tok karnına",
    ///        "scheduleTimes": ["08:00:00", "20:00:00"],
    ///        "daysOfWeek": "0,1,2,3,4,5,6",
    ///        "startDate": "2026-11-24T00:00:00Z",
    ///        "endDate": null,
    ///        "isActive": true
    ///     }
    /// </remarks>
    /// <param name="id">The unique Guid of the Medicine to update.</param>
    /// <param name="request">The full new state of the medicine.</param>
    /// <response code="200">Updated. Returns the medicine as saved.</response>
    /// <response code="400">If validation fails.</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    /// <response code="404">If the medicine ID does not exist.</response>
    [Authorize(Roles = CareTeamRoles)]
    [HttpPut("{id}")]
    [ProducesResponseType(typeof(MedicineResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateMedicine(Guid id, [FromBody] UpdateMedicineRequest request)
    {
        return await Run(() => _medicineService.UpdateMedicineAsync(id, request));
    }

    /// <summary>
    /// Permanently deletes a medicine (all of its times) and its upcoming pending doses.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    /// Warning: This is a hard delete. To pause a medicine, use PUT with `isActive: false`.
    /// </remarks>
    /// <param name="id">The unique Guid of the Medicine to delete.</param>
    /// <response code="204">Successfully deleted. No content returned.</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    /// <response code="404">If the medicine ID does not exist.</response>
    [Authorize(Roles = CareTeamRoles)]
    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteMedicine(Guid id)
    {
        try
        {
            await _medicineService.DeleteMedicineAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { Error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to delete medicine {MedicineId}.", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new { Error = "The medicine could not be deleted." });
        }
    }

    /// <summary>Runs a service call and maps validation / not-found errors to 400 / 404.</summary>
    private async Task<IActionResult> Run<T>(Func<Task<T>> action)
    {
        try
        {
            return Ok(await action());
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { Error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Medicine request failed.");
            return StatusCode(StatusCodes.Status500InternalServerError, new { Error = "The request could not be completed. Please try again later." });
        }
    }
}