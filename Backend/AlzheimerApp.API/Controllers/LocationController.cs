using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlzheimerApp.API.Controllers;

[Authorize] 
[ApiController]
[Route("api/[controller]")]
public class LocationController : ControllerBase
{
    private readonly ILocationService _locationService;

    public LocationController(ILocationService locationService)
    {
        _locationService = locationService;
    }

    [HttpPost("log")]
    public async Task<IActionResult> LogLocation([FromBody] LocationDto dto)
    {
        try
        {
            var locationLog = await _locationService.LogLocationAsync(dto);
            return Ok(locationLog);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }
}