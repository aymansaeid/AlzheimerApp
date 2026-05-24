using AlzheimerApp.Application.DTOs.Medicines;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Manages the master medication schedules for Patients.
/// </summary>
/// <remarks>
/// Strict Role-Based Access Control (RBAC) is enforced here. Patients can read their schedules, 
/// but only the Care Team (Followers/Admins) can mutate (Create, Update, Delete) the schedules.
/// </remarks>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class MedicineController : ControllerBase
{
    private readonly IMedicineService _medicineService;

    public MedicineController(IMedicineService medicineService)
    {
        _medicineService = medicineService;
    }

    /// <summary>
    /// Creates a new medication schedule for a patient.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    /// 
    /// **Important Fields:**
    /// * `DaysOfWeek`: A string of comma-separated numbers (0 = Sunday, 1 = Monday, etc.). Example: `"1,3,5"` for Mon/Wed/Fri.
    /// * `ScheduleTime`: The exact time of day in `HH:MM:SS` format.
    /// </remarks>
    /// <response code="200">Successfully created the medication schedule. Returns the created record.</response>
    /// <response code="400">If the input validation fails.</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpPost]
    [ProducesResponseType(typeof(MedicineResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> AddMedicine([FromBody] MedicineRequest request)
    {
        try
        {
            var response = await _medicineService.AddMedicineAsync(request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Retrieves all active medication schedules for a specific patient.
    /// </summary>
    /// <remarks>
    /// **Flutter Note:** This returns the *Master Schedule* rules, not today's actual status. 
    /// If you want to know if a patient actually took their pill today, use the `MedicineLogs` endpoints instead.
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <response code="200">Returns a list of active medications.</response>
    /// <response code="400">If the patient is not found or the request fails.</response>
    [HttpGet("patient/{patientId}")]
    [ProducesResponseType(typeof(List<MedicineResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetPatientMedicines(Guid patientId)
    {
        try
        {
            var response = await _medicineService.GetPatientMedicinesAsync(patientId);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Updates an existing medication schedule.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    /// Use this to update dosages, change the active days, or disable a medicine completely by setting `isActive: false`.
    /// </remarks>
    /// <param name="id">The unique Guid of the Medicine schedule to update.</param>
    /// <response code="204">Successfully updated. No content returned.</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    /// <response code="404">If the medicine ID does not exist.</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpPut("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateMedicine(Guid id, [FromBody] UpdateMedicineRequest request)
    {
        try
        {
            await _medicineService.UpdateMedicineAsync(id, request);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Permanently deletes a medication schedule from the database.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    /// Warning: This is a hard delete. For a soft delete, use the PUT endpoint and set `isActive` to false.
    /// </remarks>
    /// <param name="id">The unique Guid of the Medicine schedule to delete.</param>
    /// <response code="204">Successfully deleted. No content returned.</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    /// <response code="404">If the medicine ID does not exist.</response>
    [Authorize(Roles = "Follower,Admin")]
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
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }
}