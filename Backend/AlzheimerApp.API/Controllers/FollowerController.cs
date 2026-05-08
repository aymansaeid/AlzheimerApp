using AlzheimerApp.Application.DTOs.Followers;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

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

    [HttpPost("invite/generate")]
    public async Task<IActionResult> GenerateInvite([FromBody] GenerateInviteRequest request)
    {
        try
        {
            var response = await _followerService.GenerateInviteAsync(request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    [HttpPost("invite/accept")]
    public async Task<IActionResult> AcceptInvite([FromBody] AcceptInviteRequest request)
    {
        try
        {
            // Get the ID of the person who just clicked the link and logged in
            var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid followerId))
            {
                return Unauthorized(new { Error = "Invalid token claims." });
            }

            var response = await _followerService.AcceptInviteAsync(followerId, request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    [HttpGet("patient/{patientId}/has-admin")]
    public async Task<IActionResult> CheckIfPatientHasAdmin(Guid patientId)
    {
        try
        {
            // We bypass the service for a simple boolean read to keep it fast
            bool hasAdmin = await _followerService.CheckHasAdminAsync(patientId);
            return Ok(new { HasAdmin = hasAdmin });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    [HttpPut("patient/{patientId}/transfer-admin/{newAdminId}")]
    public async Task<IActionResult> TransferAdminRights(Guid patientId, Guid newAdminId)
    {
        try
        {
            var currentAdminIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (!Guid.TryParse(currentAdminIdString, out Guid currentAdminId))
            {
                return Unauthorized();
            }

            await _followerService.TransferAdminRightsAsync(patientId, currentAdminId, newAdminId);
            return NoContent();
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }
}
