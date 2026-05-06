using AlzheimerApp.Application.DTOs.MedicineLogs;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlzheimerApp.API.Controllers;

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

    [HttpGet("patient/{patientId}/date/{date}")]
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

    [HttpPut("{id}/status")]
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