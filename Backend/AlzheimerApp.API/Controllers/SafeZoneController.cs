using AlzheimerApp.Application.DTOs.SafeZones;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using AlzheimerApp.API.Extensions;
namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Manages geographic Safe Zones (Geofences) for Patients to monitor wandering.
/// </summary>
/// <remarks>
/// **System Architecture Note:** /// The coordinates and radius defined here are used by the backend location tracking system (via the Haversine formula) 
/// to automatically generate Emergency Alerts if a Patient leaves these designated areas.
/// 
/// Strict Role-Based Access Control (RBAC) is enforced. Only the Care Team (Followers/Admins) can modify these zones.
/// </remarks>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class SafeZoneController : ControllerBase
{
    private readonly ISafeZoneService _safeZoneService;
    private readonly ICareTeamAccessService _access;

    public SafeZoneController(ISafeZoneService safeZoneService, ICareTeamAccessService access)
    {
        _safeZoneService = safeZoneService;
        _access = access;
    }

    /// <summary>404 if the zone does not exist, 403 unless the caller is the primary caregiver; null when allowed.</summary>
    private async Task<IActionResult?> CheckCanManageAsync(Guid safeZoneId)
    {
        var patientId = await _access.GetSafeZonePatientIdAsync(safeZoneId);
        if (patientId == null) return NotFound(new { Error = "Safe zone not found." });

        return (await _access.GetPermissionsAsync(User, patientId.Value)).CanManageSafeZones
            ? null
            : this.NoPermission("Only the patient's primary caregiver can change safe zones.");
    }

    /// <summary>
    /// Creates a new geographic Safe Zone for a patient.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    /// 
    /// **Flutter Integration:** /// When the Follower taps the map, grab the Latitude and Longitude. 
    /// Provide a slider in the UI to let them set the `RadiusMeters` (e.g., 500 meters).
    /// </remarks>
    /// <response code="200">Successfully created the Safe Zone. Returns the created database record.</response>
    /// <response code="400">If the data is invalid (e.g., missing coordinates or negative radius).</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpPost]
    [ProducesResponseType(typeof(SafeZoneResponse), StatusCodes.Status200OK)] // Adjust 'SafeZoneResponse' if your DTO is named differently
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> CreateSafeZone([FromBody] CreateSafeZoneDto dto)
    {
        if (!(await _access.GetPermissionsAsync(User, dto.PatientId)).CanManageSafeZones)
            return this.NoPermission("Only the patient's primary caregiver can add safe zones.");

        try
        {
            var zone = await _safeZoneService.CreateSafeZoneAsync(dto);
            return Ok(zone);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Updates the geographic boundaries or status of an existing Safe Zone.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    /// 
    /// **Pro Tip:** Use this endpoint to temporarily disable a zone by setting `IsActive: false` 
    /// (e.g., if the patient goes on vacation) instead of deleting it permanently.
    /// </remarks>
    /// <param name="id">The unique Guid of the Safe Zone to update.</param>
    /// <response code="204">Successfully updated the Safe Zone. No content returned.</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    /// <response code="404">If the Safe Zone ID does not exist in the database.</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpPut("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateSafeZone(Guid id, [FromBody] UpdateSafeZoneRequest request)
    {
        var check = await CheckCanManageAsync(id);
        if (check != null) return check;
        try
        {
            await _safeZoneService.UpdateSafeZoneAsync(id, request);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Permanently deletes a Safe Zone from the database.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    /// Warning: This is a hard delete. The system will immediately stop tracking the patient against this geofence.
    /// </remarks>
    /// <param name="id">The unique Guid of the Safe Zone to delete.</param>
    /// <response code="204">Successfully deleted the Safe Zone. No content returned.</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    /// <response code="404">If the Safe Zone ID does not exist in the database.</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteSafeZone(Guid id)
    {
        try
        {
            await _safeZoneService.DeleteSafeZoneAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }
}