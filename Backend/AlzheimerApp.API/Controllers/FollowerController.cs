using AlzheimerApp.Application.DTOs.Followers;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlzheimerApp.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class FollowerController : ControllerBase
{
    private readonly IPatientFollowerService _followerService;

    public FollowerController(IPatientFollowerService followerService)
    {
        _followerService = followerService;
    }

    [HttpPost("link")]
    public async Task<IActionResult> LinkFollowerToPatient([FromBody] FollowerRequest request)
    {
        try
        {
            var response = await _followerService.AddFollowerAsync(request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }
}