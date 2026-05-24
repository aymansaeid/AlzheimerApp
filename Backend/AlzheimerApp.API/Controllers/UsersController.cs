using AlzheimerApp.Application.DTOs.Users;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Manages user profile settings and physical device integrations.
/// </summary>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    /// <summary>
    /// Updates the physical device's Firebase Cloud Messaging (FCM) Token for Push Notifications.
    /// </summary>
    /// <remarks>
    /// **CRITICAL FOR FLUTTER DEVELOPER:**
    /// Without this token, the backend cannot send emergency push notifications to the user's phone.
    /// 
    /// **When to call this:**
    /// 1. Immediately after the user logs in successfully.
    /// 2. Every time the app starts up (in case Firebase rotated the device token in the background).
    /// 
    /// **Security Note:**
    /// You do not need to send the `userId`. The backend securely extracts the User ID directly from the attached JWT Bearer token.
    /// </remarks>
    /// <response code="204">Successfully updated the FCM token in the database. No content returned.</response>
    /// <response code="400">If the request is malformed or the database update fails.</response>
    /// <response code="401">If the JWT token is missing, expired, or invalid.</response>
    [HttpPut("fcm-token")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> UpdateFcmToken([FromBody] UpdateFcmTokenRequest request)
    {
        try
        {
            // Safely extract the logged-in user's ID from their JWT token
            var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
            {
                return Unauthorized(new { Error = "Invalid token claims." });
            }

            await _userService.UpdateFcmTokenAsync(userId, request.FcmToken);
            return NoContent();
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }
}