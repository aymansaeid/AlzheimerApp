using AlzheimerApp.API.Hubs;
using AlzheimerApp.Application.DTOs.Locations;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

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

    public LocationController(ILocationService locationService, IHubContext<LocationHub> hubContext)
    {
        _locationService = locationService;
        _hubContext = hubContext;
    }

    /// <summary>
    /// Logs a Patient's current GPS coordinates and broadcasts the update via WebSockets.
    /// </summary>
    /// <remarks>
    /// **Flutter Developer Note (CRITICAL):**
    /// This endpoint does two things simultaneously:
    /// 1. Saves the exact GPS coordinates to the PostgreSQL database for historical tracking.
    /// 2. Instantly fires a WebSocket event to update the map in real-time.
    /// 
    /// **SignalR Connection Details:**
    /// * **Hub URL:** `/hubs/location`
    /// * **Group Name:** `PatientTracker_{patientId}` (You must join this group upon connecting).
    /// * **Listener Event:** `ReceiveLocationUpdate` (Listen for this string to trigger a state update on the map).
    /// 
    /// Sample Request:
    /// 
    ///     POST /api/location/log
    ///     {
    ///        "patientId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    ///        "latitude": 41.0082,
    ///        "longitude": 28.9784
    ///     }
    /// </remarks>
    /// <response code="200">Location logged and WebSocket event fired successfully. Returns the saved log.</response>
    /// <response code="400">If the GPS data is invalid or the database fails to save.</response>
    [HttpPost("log")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> LogLocation([FromBody] LocationRequest dto)
    {
        try
        {
            // 1. Save to the PostgreSQL Database (Business Logic)
            var locationLog = await _locationService.LogLocationAsync(dto);

            // 2. 🚀 INSTANT BROADCAST TO FLUTTER VIA WEBSOCKETS!
            string groupName = $"PatientTracker_{dto.PatientId}";

            // This tells Flutter: "Hey, listen for the 'ReceiveLocationUpdate' event!"
            await _hubContext.Clients.Group(groupName).SendAsync("ReceiveLocationUpdate", new
            {
                locationLog.PatientId,
                locationLog.Latitude,
                locationLog.Longitude,
                locationLog.RecordedAt
            });

            return Ok(locationLog);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }
    /// <summary>
    /// Gets the absolute latest known location of a patient.
    /// </summary>
    /// <remarks>
    /// **Flutter Note:** Call this endpoint immediately when opening the map screen to place the initial marker 
    /// before waiting for real-time WebSocket updates.
    /// </remarks>
    [HttpGet("patient/{patientId}/latest")]
    [ProducesResponseType(typeof(LocationLogResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetLatestLocation(Guid patientId)
    {
        try
        {
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
    /// **Flutter Note:** Use this to draw a "Polyline" (path) on the map showing where the patient has been today.
    /// </remarks>
    [HttpGet("patient/{patientId}/history")]
    [ProducesResponseType(typeof(List<LocationLogResponse>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetLocationHistory(
        Guid patientId,
        [FromQuery] DateTime startTime,
        [FromQuery] DateTime endTime)
    {
        try
        {
            var history = await _locationService.GetLocationHistoryAsync(patientId, startTime, endTime);
            return Ok(history);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }
}