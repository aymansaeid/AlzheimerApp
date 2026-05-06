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

    // Only Followers/Admins can upload photos/voices
    [Authorize(Roles = "Follower,Admin")]
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

    // Anyone (including the Patient) can fetch the memories to look at them
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

    // Only Followers/Admins can update
    [Authorize(Roles = "Follower,Admin")]
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateContent(Guid id, [FromBody] UpdateMemoryContentRequest request)
    {
        try
        {
            await _contentService.UpdateContentAsync(id, request);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }

    // Only Followers/Admins can delete
    [Authorize(Roles = "Follower,Admin")]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteContent(Guid id)
    {
        try
        {
            await _contentService.DeleteContentAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }
}