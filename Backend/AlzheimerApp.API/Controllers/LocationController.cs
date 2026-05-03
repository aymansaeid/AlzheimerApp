using AlzheimerApp.API.Hubs;
using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace AlzheimerApp.API.Controllers;

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

    [HttpPost("log")]
    public async Task<IActionResult> LogLocation([FromBody] LocationDto dto)
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
}