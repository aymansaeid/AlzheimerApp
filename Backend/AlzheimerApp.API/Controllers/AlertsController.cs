using AlzheimerApp.Application.DTOs.Alerts;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using AlzheimerApp.API.Extensions;
namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Manages emergency alerts and notifications for patients.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class AlertsController : ControllerBase
{
    private readonly IAlertService _alertService;
    private readonly ICareTeamAccessService _access;

    public AlertsController(IAlertService alertService, ICareTeamAccessService access)
    {
        _alertService = alertService;
        _access = access;
    }

    /// <summary>
    /// Retrieves the entire alert history for a specific patient.
    /// </summary>
    /// <remarks>
    /// The Flutter app should call this to populate the "Notification Center" screen. 
    /// Alerts are returned in descending order (newest first). 
    /// Check the `isRead` boolean to determine if the alert should be highlighted as new.
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <response code="200">Returns a list of all past alerts.</response>
    /// <response code="400">If the request fails or the patient is not found.</response>
    [HttpGet("patient/{patientId}")]
    [ProducesResponseType(typeof(List<AlertResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetPatientAlerts(Guid patientId)
    {
        if (!(await _access.GetPermissionsAsync(User, patientId)).CanView) return this.NoPermission();
        try
        {
            var response = await _alertService.GetPatientAlertsAsync(patientId);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Marks a specific alert as "Read".
    /// </summary>
    /// <remarks>
    /// The Flutter app should call this endpoint the moment a Follower taps on an unread notification in the UI. 
    /// This clears the alert so it no longer counts towards the "Unread" badge on the home screen.
    /// </remarks>
    /// <param name="id">The unique Guid of the specific Alert.</param>
    /// <response code="204">Successfully marked as read. No content is returned.</response>
    /// <response code="404">If the specific alert ID does not exist in the database.</response>
    [HttpPut("{id}/read")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> MarkAsRead(Guid id)
    {
        var patientId = await _access.GetAlertPatientIdAsync(id);
        if (patientId == null) return NotFound(new { Error = "Alert not found." });
        if (!(await _access.GetPermissionsAsync(User, patientId.Value)).CanView) return this.NoPermission();
        try
        {
            await _alertService.MarkAlertAsReadAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }
}