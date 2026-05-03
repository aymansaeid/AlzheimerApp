using AlzheimerApp.Application.DTOs.MemoryContents;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlzheimerApp.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class MemoryContentController : ControllerBase
{
    private readonly IMemoryContentService _contentService;

    public MemoryContentController(IMemoryContentService contentService)
    {
        _contentService = contentService;
    }

    [HttpPost]
    public async Task<IActionResult> AddContent([FromBody] MemoryContentRequest request)
    {
        try
        {
            var response = await _contentService.AddContentAsync(request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    [HttpGet("patient/{patientId}")]
    public async Task<IActionResult> GetPatientContent(Guid patientId)
    {
        try
        {
            var response = await _contentService.GetPatientContentAsync(patientId);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }
}