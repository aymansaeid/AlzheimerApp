using AlzheimerApp.Application.DTOs.SafeZones;
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

    [Authorize(Roles = "Follower,Admin")]
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

    [Authorize(Roles = "Follower,Admin")]
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateSafeZone(Guid id, [FromBody] UpdateSafeZoneRequest request)
    {
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

    [Authorize(Roles = "Follower,Admin")]
    [HttpDelete("{id}")]
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