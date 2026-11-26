using AlzheimerApp.API.Extensions;
using AlzheimerApp.API.Hubs;
using AlzheimerApp.Application.DTOs.SafeZones;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Manages geographic Safe Zones (Geofences) for Patients to monitor wandering.
/// </summary>
/// <remarks>
/// **System Architecture Note:** The coordinates and radius defined here are used by the backend location tracking system
/// (via the Haversine formula) to automatically generate Emergency Alerts if a Patient leaves these designated areas.
///
/// **Permissions:** viewing = `permissions.canView`; adding / editing / deleting = `permissions.canManageSafeZones`
/// (primary caregiver or system admin).
///
/// **Real-time:** after every add / edit / delete, the SignalR event `SafeZonesUpdated` is sent to everyone subscribed
/// to that patient on `/hubs/location` (same subscription as `ReceiveLocationUpdate`), with the patient's full list of
/// ACTIVE zones: `{ patientId, safeZones: [...] }`. Replace that patient's circles with the list; no extra request needed.
/// </remarks>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class SafeZoneController : ControllerBase
{
    private readonly ISafeZoneService _safeZoneService;
    private readonly ICareTeamAccessService _access;
    private readonly IHubContext<LocationHub> _hubContext;
    private readonly ILogger<SafeZoneController> _logger;

    public SafeZoneController(
        ISafeZoneService safeZoneService,
        ICareTeamAccessService access,
        IHubContext<LocationHub> hubContext,
        ILogger<SafeZoneController> logger)
    {
        _safeZoneService = safeZoneService;
        _access = access;
        _hubContext = hubContext;
        _logger = logger;
    }

    /// <summary>
    /// Lists a patient's safe zones (to draw them on the map / show them in the safe zone screen).
    /// </summary>
    /// <remarks>
    /// **Security:** the patient, any care team member, or a system admin (`permissions.canView`).
    /// Adding / editing / deleting stays primary-caregiver only (`permissions.canManageSafeZones`).
    ///
    /// By default only **active** zones are returned (the ones the breach check uses).
    /// Send `?includeInactive=true` on the management screen to also list paused zones.
    ///
    /// **Tip:** for the overview map you do not need this per patient: `GET /api/Location/patients/latest`
    /// already contains every patient's active `safeZones`.
    ///
    ///     GET /api/SafeZone/patient/{patientId}
    ///     [
    ///       {
    ///         "id": "6a1f...",
    ///         "patientId": "019e...",
    ///         "name": "Ev",
    ///         "centerLat": 41.0082,
    ///         "centerLng": 28.9784,
    ///         "radiusMeters": 500,
    ///         "isActive": true,
    ///         "createdAt": "2026-11-20T10:15:00Z"
    ///       }
    ///     ]
    /// </remarks>
    /// <param name="patientId">The patient's user id.</param>
    /// <param name="includeInactive">Also return paused (inactive) zones. Default false.</param>
    /// <response code="200">The zones, oldest first. Empty list if none.</response>
    /// <response code="403">If the caller may not see this patient.</response>
    [HttpGet("patient/{patientId}")]
    [ProducesResponseType(typeof(List<SafeZoneResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetPatientSafeZones(Guid patientId, [FromQuery] bool includeInactive = false)
    {
        if (!(await _access.GetPermissionsAsync(User, patientId)).CanView) return this.NoPermission();

        return Ok(await _safeZoneService.GetPatientSafeZonesAsync(patientId, includeInactive));
    }

    /// <summary>
    /// Creates a new geographic Safe Zone for a patient.
    /// </summary>
    /// <remarks>
    /// **Security:** primary caregiver or system admin (`permissions.canManageSafeZones`).
    ///
    /// **Flutter Integration:** When the Follower taps the map, grab the Latitude and Longitude.
    /// Provide a slider in the UI to let them set the `RadiusMeters` (e.g., 500 meters).
    /// Other open apps receive the change via the `SafeZonesUpdated` SignalR event.
    /// </remarks>
    /// <response code="200">Successfully created the Safe Zone. Returns the created record.</response>
    /// <response code="400">If the data is invalid.</response>
    /// <response code="403">If the caller is not the patient's primary caregiver.</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpPost]
    [ProducesResponseType(typeof(SafeZoneResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> CreateSafeZone([FromBody] CreateSafeZoneDto dto)
    {
        if (!(await _access.GetPermissionsAsync(User, dto.PatientId)).CanManageSafeZones)
            return this.NoPermission("Only the patient's primary caregiver can add safe zones.");

        try
        {
            var zone = await _safeZoneService.CreateSafeZoneAsync(dto);
            await BroadcastSafeZonesAsync(dto.PatientId);
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
    /// **Security:** primary caregiver or system admin (`permissions.canManageSafeZones`).
    ///
    /// **Pro Tip:** Use this endpoint to temporarily disable a zone by setting `IsActive: false`
    /// (e.g., if the patient goes on vacation) instead of deleting it permanently.
    /// Other open apps receive the change via the `SafeZonesUpdated` SignalR event.
    /// </remarks>
    /// <param name="id">The unique Guid of the Safe Zone to update.</param>
    /// <param name="request">The new name, center, radius and active flag.</param>
    /// <response code="204">Successfully updated the Safe Zone. No content returned.</response>
    /// <response code="403">If the caller is not the patient's primary caregiver.</response>
    /// <response code="404">If the Safe Zone ID does not exist in the database.</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpPut("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateSafeZone(Guid id, [FromBody] UpdateSafeZoneRequest request)
    {
        var (error, patientId) = await CheckCanManageAsync(id);
        if (error != null) return error;

        try
        {
            await _safeZoneService.UpdateSafeZoneAsync(id, request);
            await BroadcastSafeZonesAsync(patientId);
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
    /// **Security:** primary caregiver or system admin (`permissions.canManageSafeZones`).
    /// Warning: This is a hard delete. The system will immediately stop tracking the patient against this geofence.
    /// Other open apps receive the change via the `SafeZonesUpdated` SignalR event.
    /// </remarks>
    /// <param name="id">The unique Guid of the Safe Zone to delete.</param>
    /// <response code="204">Successfully deleted the Safe Zone. No content returned.</response>
    /// <response code="403">If the caller is not the patient's primary caregiver.</response>
    /// <response code="404">If the Safe Zone ID does not exist in the database.</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteSafeZone(Guid id)
    {
        var (error, patientId) = await CheckCanManageAsync(id);
        if (error != null) return error;

        try
        {
            await _safeZoneService.DeleteSafeZoneAsync(id);
            await BroadcastSafeZonesAsync(patientId);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }

    /// <summary>404 if the zone does not exist, 403 unless the caller may manage it; otherwise (null, the zone's patient).</summary>
    private async Task<(IActionResult? Error, Guid PatientId)> CheckCanManageAsync(Guid safeZoneId)
    {
        var patientId = await _access.GetSafeZonePatientIdAsync(safeZoneId);
        if (patientId == null) return (NotFound(new { Error = "Safe zone not found." }), Guid.Empty);

        return (await _access.GetPermissionsAsync(User, patientId.Value)).CanManageSafeZones
            ? (null, patientId.Value)
            : (this.NoPermission("Only the patient's primary caregiver can change safe zones."), patientId.Value);
    }

    /// <summary>
    /// Sends the patient's current ACTIVE zones to every app subscribed to this patient (SignalR <c>SafeZonesUpdated</c>).
    /// Best effort: the change is already saved, so a broadcast failure never fails the request.
    /// </summary>
    private async Task BroadcastSafeZonesAsync(Guid patientId)
    {
        try
        {
            var zones = await _safeZoneService.GetPatientSafeZonesAsync(patientId);
            await _hubContext.Clients.Group(LocationHub.GroupFor(patientId))
                .SendAsync("SafeZonesUpdated", new { patientId, safeZones = zones });
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Could not broadcast safe zone change for patient {PatientId}.", patientId);
        }
    }
}