using AlzheimerApp.API.Hubs;
using AlzheimerApp.Application.DTOs.Locations;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;
namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Handles real-time geographic tracking, database logging, and WebSocket broadcasting for Patients.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class LocationController : ControllerBase
{
    private readonly ILocationService _locationService;
    private readonly IHubContext<LocationHub> _hubContext;
    private readonly ILogger<LocationController> _logger;

    public LocationController(ILocationService locationService, IHubContext<LocationHub> hubContext, ILogger<LocationController> logger)
    {
        _locationService = locationService;
        _hubContext = hubContext;
        _logger = logger;
    }

    // NOTE: The role is named "Follower" in UserRole (not "Caregiver"). nameof keeps this attribute
    // in sync with the enum, so a rename can never silently turn the endpoint into a 403 for caregivers.
    /// <summary>
    /// Gets the latest known location of every patient the logged-in caregiver tracks, in one call.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` (caregiver) or `Admin` role.
    /// * **Follower:** returns only the patients linked to the caller (same list as `/api/Follower/my-patients`).
    /// * **Admin:** returns every patient in the system.
    ///
    /// The caller is identified from the JWT token. No IDs are sent.
    ///
    /// **Flutter Note:** Use this to place all patient markers (with their profile photos) on the overview map
    /// in a single request, then keep them live with the `ReceiveLocationUpdate` SignalR event.
    /// Patients who have never sent a location are still listed, with `latestLocation: null`.
    /// The list is sorted by `fullName`.
    ///
    /// Sample response:
    ///
    ///     [
    ///       {
    ///         "patientId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    ///         "fullName": "Ayşe Yılmaz",
    ///         "profilePhotoUrl": "https://firebasestorage.googleapis.com/v0/b/...",
    ///         "latestLocation": {
    ///           "latitude": 41.0082,
    ///           "longitude": 28.9784,
    ///           "timestamp": "2026-11-24T10:15:00Z",
    ///           "isInsideSafeZone": true
    ///         }
    ///       },
    ///       {
    ///         "patientId": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    ///         "fullName": "Mehmet Demir",
    ///         "profilePhotoUrl": null,
    ///         "latestLocation": null
    ///       }
    ///     ]
    /// </remarks>
    /// <param name="cancellationToken">Cancelled when the client disconnects.</param>
    /// <response code="200">Returns one entry per patient. An empty list means the caregiver tracks no patients.</response>
    /// <response code="401">If the JWT token is missing, expired, or invalid.</response>
    /// <response code="403">If the caller is a Patient.</response>
    [Authorize(Roles = $"{nameof(UserRole.Follower)},{nameof(UserRole.Admin)}")]
    [HttpGet("patients/latest")]
    [ProducesResponseType(typeof(List<PatientLatestLocationResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetLatestLocationsForMyPatients(CancellationToken cancellationToken)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid requesterId))
        {
            return Unauthorized(new { Error = "Invalid token claims." });
        }

        try
        {
            bool isSystemAdmin = User.IsInRole(nameof(UserRole.Admin));
            var response = await _locationService.GetLatestLocationsForCareTeamAsync(requesterId, isSystemAdmin, cancellationToken);
            return Ok(response);
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            _logger.LogError(ex, "Failed to load latest patient locations for user {UserId}.", requesterId);
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { Error = "Patient locations could not be loaded. Please try again later." });
        }
    }


    /// <summary>
    /// Logs the logged-in Patient's current GPS coordinates and battery level, and broadcasts the update via WebSockets.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Patient` role. The patient is taken from the JWT token,
    /// so **no `patientId` is sent** (if an old app version still sends one, it is ignored).
    ///
    /// This endpoint does three things:
    /// 1. Saves the GPS coordinates (and battery level) to PostgreSQL for history and the map.
    /// 2. Runs the safe-zone check and push-notifies the care team on a new breach.
    /// 3. Fires the `ReceiveLocationUpdate` WebSocket event so open maps update instantly.
    ///
    /// **SignalR Connection Details:**
    /// * **Hub URL:** `/hubs/location?access_token={jwt}` (WebSockets cannot send headers; the token goes in the query string).
    /// * **Subscribe:** call hub method `SubscribeToPatientTracking(patientId)` after connecting. Only the patient,
    ///   linked care team members and admins are allowed; others get a `HubException`.
    /// * **Listener Event:** `ReceiveLocationUpdate` with payload
    ///   `{ patientId, latitude, longitude, recordedAt, isOutsideZone, batteryLevel, isCharging }`.
    ///
    /// Sample Request:
    ///
    ///     POST /api/location/log
    ///     {
    ///        "latitude": 41.0082,
    ///        "longitude": 28.9784,
    ///        "accuracyMeters": 12,
    ///        "batteryLevel": 82,
    ///        "isCharging": false
    ///     }
    ///
    /// `batteryLevel` (0–100) and `isCharging` are optional.
    /// </remarks>
    /// <response code="200">Location logged and WebSocket event fired. Returns the saved record.</response>
    /// <response code="400">If the coordinates or battery level are out of range.</response>
    /// <response code="401">If the JWT token is missing, expired, or invalid.</response>
    /// <response code="403">If the caller is not a Patient.</response>
    [Authorize(Roles = nameof(UserRole.Patient))]
    [HttpPost("log")]
    [ProducesResponseType(typeof(LocationLogResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> LogLocation([FromBody] LocationRequest dto)
    {
        if (!TryGetUserId(out var patientId))
        {
            return Unauthorized(new { Error = "Invalid token claims." });
        }

        try
        {
            // 1. Save to the PostgreSQL Database (Business Logic)
            var locationLog = await _locationService.LogLocationAsync(patientId, dto);

            // 2. 🚀 INSTANT BROADCAST TO FLUTTER VIA WEBSOCKETS!
            string groupName = $"PatientTracker_{patientId}";

            // This tells Flutter: "Hey, listen for the 'ReceiveLocationUpdate' event!"
            await _hubContext.Clients.Group(groupName).SendAsync("ReceiveLocationUpdate", new
            {
                locationLog.PatientId,
                locationLog.Latitude,
                locationLog.Longitude,
                locationLog.RecordedAt,
                locationLog.IsOutsideZone,
                locationLog.BatteryLevel,
                locationLog.IsCharging
            });

            return Ok(locationLog);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to log location for patient {PatientId}.", patientId);
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { Error = "The location could not be saved. Please try again later." });
        }
    }

    /// <summary>
    /// Gets the absolute latest known location of a patient.
    /// </summary>
    /// <remarks>
    /// **Security:** the patient themself, a linked care team member, or an Admin.
    ///
    /// **Flutter Note:** Call this endpoint immediately when opening the map screen to place the initial marker
    /// before waiting for real-time WebSocket updates. Includes `batteryLevel` and `isCharging`.
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <response code="200">Returns the latest location.</response>
    /// <response code="403">If the caller is not allowed to see this patient.</response>
    /// <response code="404">If the patient has not sent any location yet.</response>
    [HttpGet("patient/{patientId}/latest")]
    [ProducesResponseType(typeof(LocationLogResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetLatestLocation(Guid patientId)
    {
        try
        {
            if (!await CanTrackAsync(patientId)) return Forbid();

            var location = await _locationService.GetLatestLocationAsync(patientId);
            if (location == null) return NotFound(new { Message = "No location data found for this patient yet." });

            return Ok(location);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Gets the location history of a patient within a specific time window.
    /// </summary>
    /// <remarks>
    /// **Security:** the patient themself, a linked care team member, or an Admin.
    ///
    /// **Flutter Note:** Use this to draw a "Polyline" (path) on the map showing where the patient has been today.
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <param name="startTime">Start of the window (UTC, ISO 8601).</param>
    /// <param name="endTime">End of the window (UTC, ISO 8601).</param>
    /// <response code="200">Returns the points ordered from oldest to newest.</response>
    /// <response code="403">If the caller is not allowed to see this patient.</response>
    [HttpGet("patient/{patientId}/history")]
    [ProducesResponseType(typeof(List<LocationLogResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetLocationHistory(
        Guid patientId,
        [FromQuery] DateTime startTime,
        [FromQuery] DateTime endTime)
    {
        try
        {
            if (!await CanTrackAsync(patientId)) return Forbid();

            var history = await _locationService.GetLocationHistoryAsync(patientId, startTime, endTime);
            return Ok(history);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    private bool TryGetUserId(out Guid userId)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return Guid.TryParse(userIdString, out userId);
    }

    private async Task<bool> CanTrackAsync(Guid patientId)
    {
        if (!TryGetUserId(out var userId)) return false;
        return await _locationService.CanTrackPatientAsync(userId, User.IsInRole(nameof(UserRole.Admin)), patientId);
    }
}
