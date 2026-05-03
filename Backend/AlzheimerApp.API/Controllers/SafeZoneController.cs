using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlzheimerApp.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class SafeZoneController : ControllerBase
{
    private readonly ISafeZoneService _safeZoneService;

    public SafeZoneController(ISafeZoneService safeZoneService)
    {
        _safeZoneService = safeZoneService;
    }

    [HttpPost]
    public async Task<IActionResult> CreateSafeZone([FromBody] CreateSafeZoneDto dto)
    {
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
}