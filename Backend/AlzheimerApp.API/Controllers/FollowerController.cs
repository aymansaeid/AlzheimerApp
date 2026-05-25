using AlzheimerApp.Application.DTOs.Followers;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Manages the relationships between Patients and their Care Team (Followers), including the invitation system and dashboard data.
/// </summary>
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

    /// <summary>
    /// Manually links a Follower to a Patient.
    /// </summary>
    /// <remarks>
    /// Note: It is highly recommended to use the Invite System (`/invite/generate` and `/invite/accept`) instead of this manual endpoint for better UX.
    /// </remarks>
    /// <response code="200">Returns the newly created relationship details.</response>
    /// <response code="400">If the users are already linked or validation fails.</response>
    [HttpPost("link")]
    [ProducesResponseType(typeof(FollowerResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
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

    /// <summary>
    /// Generates a secure, 6-character Invite Code and Deep Link for the Care Team.
    /// </summary>
    /// <remarks>
    /// **Scenario:** The Patient's app hits this to generate an Admin QR code, OR an existing Admin hits this to invite a standard viewer.
    /// 
    /// * Set `isPrimaryInvite: true` to generate a Master Admin invite.
    /// * Set `isPrimaryInvite: false` to generate a standard viewer invite.
    /// </remarks>
    /// <response code="200">Returns the code and the Flutter Deep Link URL (`alzheimerapp://invite?code=...`).</response>
    /// <response code="400">If the generation fails.</response>
    [HttpPost("invite/generate")]
    [ProducesResponseType(typeof(InviteResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
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

    /// <summary>
    /// Consumes an invite code to securely link the logged-in user to a Patient.
    /// </summary>
    /// <remarks>
    /// The Flutter app should extract the code from the Deep Link and post it here. 
    /// The backend automatically detects the new follower's ID from their JWT Token.
    /// Once accepted successfully, the invite code is burned and cannot be reused.
    /// </remarks>
    /// <response code="200">Successfully linked. Returns the relationship details.</response>
    /// <response code="400">If the code is expired, invalid, or the user is already linked.</response>
    /// <response code="401">If the JWT token is missing or invalid.</response>
    [HttpPost("invite/accept")]
    [ProducesResponseType(typeof(FollowerResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
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

    /// <summary>
    /// Checks if a patient already has a Primary Admin assigned.
    /// </summary>
    /// <remarks>
    /// **UX Logic:** Flutter should call this when the Patient opens the app. 
    /// If `true`, go straight to the home screen. If `false`, show the "Generate Admin QR Code" screen.
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <response code="200">Returns a boolean indicating admin status.</response>
    [HttpGet("patient/{patientId}/has-admin")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> CheckIfPatientHasAdmin(Guid patientId)
    {
        try
        {
            bool hasAdmin = await _followerService.CheckHasAdminAsync(patientId);
            return Ok(new { HasAdmin = hasAdmin });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Transfers Primary Admin rights from the current admin to another member of the Care Team.
    /// </summary>
    /// <remarks>
    /// Security: Only the currently authenticated Primary Admin can execute this action.
    /// After success, the caller becomes a standard viewer, and the target becomes the new Admin.
    /// </remarks>
    /// <param name="patientId">The Guid of the Patient.</param>
    /// <param name="newAdminId">The Guid of the Care Team member receiving admin rights.</param>
    /// <response code="204">Successfully transferred rights. No content returned.</response>
    /// <response code="400">If the transfer fails or the target user is not part of the care team.</response>
    /// <response code="401">If the caller is not authenticated or not the current primary admin.</response>
    [HttpPut("patient/{patientId}/transfer-admin/{newAdminId}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
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
            return NoContent(); // 204 No Content is standard for a successful PUT
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Retrieves the aggregated "God Endpoint" dashboard data for a patient.
    /// </summary>
    /// <remarks>
    /// **Performance:** Flutter should call this single endpoint when the app loads to prevent multiple HTTP roundtrips.
    /// It returns the latest location, active alerts, and today's medicine schedule all in one package.
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <response code="200">Returns the fully aggregated dashboard data.</response>
    /// <response code="400">If the patient is not found.</response>
    [HttpGet("patient/{patientId}/dashboard")]
    [ProducesResponseType(typeof(FollowerDashboardResponse),StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> GetDashboard(Guid patientId)
    {
        try
        {
            var response = await _followerService.GetDashboardDataAsync(patientId);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }
}