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
    // Slightly above the 5 MB file limit to leave room for multipart boundaries and headers.
    // Anything larger is rejected by Kestrel with 413 before it is buffered.
    private const long MaxPhotoRequestBytes = 6 * 1024 * 1024;

    private readonly IUserService _userService;
    private readonly ILogger<UsersController> _logger;

    public UsersController(IUserService userService, ILogger<UsersController> logger)
    {
        _userService = userService;
        _logger = logger;
    }

    /// <summary>
    /// Uploads or replaces the logged-in user's profile photo.
    /// </summary>
    /// <remarks>
    /// **Request:** `multipart/form-data` with a single file field named **`file`**.
    ///
    /// **Rules:**
    /// * Max size: **5 MB**.
    /// * Allowed types: **.jpg, .jpeg, .png, .webp**. The real file signature is checked, so a renamed
    ///   file is rejected. The part's `Content-Type` header is not required.
    /// * The user is taken from the JWT token. Do not send a `userId`.
    ///
    /// The photo is stored in Firebase Storage (never on the server disk). The previous photo is deleted
    /// automatically. Every upload gets a new URL, so image caches in the app never show a stale photo.
    ///
    /// **Flutter (dio) example:**
    ///
    ///     final form = FormData.fromMap({
    ///       'file': await MultipartFile.fromFile(path, filename: 'avatar.jpg'),
    ///     });
    ///     await dio.post('/api/Users/me/photo', data: form);
    ///
    /// Sample response:
    ///
    ///     {
    ///        "profilePhotoUrl": "https://firebasestorage.googleapis.com/v0/b/.../o/profile-photos%2F...jpg?alt=media&amp;token=..."
    ///     }
    /// </remarks>
    /// <param name="file">The image file (form field name: `file`).</param>
    /// <param name="cancellationToken">Cancelled when the client disconnects.</param>
    /// <response code="200">Photo uploaded. Returns the new public URL, which is also saved on the user.</response>
    /// <response code="400">If the file is missing, empty, larger than 5 MB, or not a JPG/PNG/WEBP image.</response>
    /// <response code="401">If the JWT token is missing, expired, or invalid.</response>
    /// <response code="404">If the user in the token no longer exists.</response>
    /// <response code="413">If the request body is far larger than the 5 MB limit.</response>
    /// <response code="500">If the storage service is unavailable or not configured.</response>
    [HttpPost("me/photo")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(MaxPhotoRequestBytes)]
    [RequestFormLimits(MultipartBodyLengthLimit = MaxPhotoRequestBytes)]
    [ProducesResponseType(typeof(ProfilePhotoResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status413PayloadTooLarge)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> UploadProfilePhoto(IFormFile? file, CancellationToken cancellationToken)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out Guid userId))
        {
            return Unauthorized(new { Error = "Invalid token claims." });
        }

        if (file == null || file.Length == 0)
        {
            return BadRequest(new { Error = "No file was uploaded. Send the image in a form field named 'file'." });
        }

        try
        {
            await using var stream = file.OpenReadStream();
            var request = new ProfilePhotoUploadRequest
            {
                Content = stream,
                FileName = file.FileName,
                Length = file.Length
            };

            var response = await _userService.UpdateProfilePhotoAsync(userId, request, cancellationToken);
            return Ok(response);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { Error = ex.Message });
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            // Storage/database details are logged, not leaked to the client.
            _logger.LogError(ex, "Profile photo upload failed for user {UserId}.", userId);
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { Error = "The profile photo could not be saved. Please try again later." });
        }
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