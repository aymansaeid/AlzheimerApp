using AlzheimerApp.Application.DTOs.MedicineLogs;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Manages the daily tracking and status of a Patient's medication schedule.
/// </summary>
/// <remarks>
/// Unlike the master Medicine schedule, this controller tracks the actual day-to-day logs 
/// (e.g., whether a pill was taken, missed, or is pending today). Both Patients and the Care Team have access to these endpoints.
/// </remarks>
[Authorize] // Both Roles can access!
[ApiController]
[Route("api/[controller]")]
public class MedicineLogsController : ControllerBase
{
    private readonly IMedicineLogService _logService;

    public MedicineLogsController(IMedicineLogService logService)
    {
        _logService = logService;
    }

    /// <summary>
    /// Retrieves the daily medication log for a specific patient on a specific date.
    /// </summary>
    /// <remarks>
    /// **Smart Generator Logic:** If no logs exist for the requested date, the backend will automatically 
    /// read the master schedule and instantly generate `Pending` logs for that specific day.
    /// 
    /// **Flutter Developer Note:** /// Format the date as `YYYY-MM-DD` in the URL (e.g., `/api/MedicineLogs/patient/1234.../date/2026-05-24`).
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <param name="date">The target date to retrieve logs for.</param>
    /// <response code="200">Returns the list of medicine logs for the requested day.</response>
    /// <response code="400">If the request is invalid or the patient is not found.</response>
    [HttpGet("patient/{patientId}/date/{date}")]
    [ProducesResponseType(typeof(List<MedicineLogResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetDailyLogs(Guid patientId, DateTime date)
    {
        try
        {
            var response = await _logService.GetDailyLogsAsync(patientId, date);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Updates the status of a specific daily medicine log.
    /// </summary>
    /// <remarks>
    /// **Status Mapping (MedicineStatus Enum):**
    /// * `0` = Pending
    /// * `1` = Taken
    /// * `2` = Missed
    /// 
    /// **Scenario:** The Patient taps "I took my pill" in the Flutter app. The app hits this endpoint sending `{ "status": 1 }`.
    /// The backend will automatically timestamp when it was taken.
    /// </remarks>
    /// <param name="id">The unique Guid of the specific *Medicine Log* (NOT the master Medicine ID).</param>
    /// <response code="204">Successfully updated the log status. No content returned.</response>
    /// <response code="404">If the log ID does not exist in the database.</response>
    [HttpPut("{id}/status")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateLogStatus(Guid id, [FromBody] UpdateLogStatusRequest request)
    {
        try
        {
            await _logService.UpdateLogStatusAsync(id, request);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }
}