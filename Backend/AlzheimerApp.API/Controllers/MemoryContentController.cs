using AlzheimerApp.Application.DTOs.MemoryContents;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Manages personalized memory content (photos, voice messages, identity cards) to help patients recognize their loved ones.
/// </summary>
/// <remarks>
/// Strict Role-Based Access Control (RBAC) is enforced. Patients can view memories, but only the Care Team can upload, edit, or delete them.
/// </remarks>
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

    /// <summary>
    /// Adds a new memory (photo, voice memo, etc.) to the patient's profile.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    /// 
    /// **Flutter Developer Note (Architecture):**
    /// Do not send raw file bytes (like JPG or MP3) to this endpoint! 
    /// 1. Upload the physical file directly from Flutter to Firebase Storage.
    /// 2. Get the download URL from Firebase.
    /// 3. Pass that URL into the `fileUrl` property of this request.
    /// 
    /// **ContentType Mapping:**
    /// * `0` = Photo
    /// * `1` = Voice
    /// * `2` = IdentityCard
    /// </remarks>
    /// <response code="200">Successfully created the memory content. Returns the saved record.</response>
    /// <response code="400">If validation fails or the URL is missing.</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpPost]
    [ProducesResponseType(typeof(MemoryContentResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
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

    /// <summary>
    /// Retrieves all active memory content for a specific patient.
    /// </summary>
    /// <remarks>
    /// **Access:** Open to all authenticated users (Patients, Followers, Admins).
    /// The Flutter app should call this to build the "Memory Gallery" screen for the patient. 
    /// Memories are returned in descending order (newest first).
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <response code="200">Returns a list of all active memory contents.</response>
    /// <response code="400">If the patient is not found.</response>
    [HttpGet("patient/{patientId}")]
    [ProducesResponseType(typeof(List<MemoryContentResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
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

    /// <summary>
    /// Updates the text metadata (title, description, relationship) of an existing memory.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    /// Useful if a Follower accidentally typed "Uncle" instead of "Brother", or if they want to temporarily hide a memory by setting `isActive: false`.
    /// </remarks>
    /// <param name="id">The unique Guid of the Memory Content to update.</param>
    /// <response code="204">Successfully updated. No content returned.</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    /// <response code="404">If the memory content ID does not exist.</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpPut("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
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

    /// <summary>
    /// Permanently deletes a memory from the patient's profile.
    /// </summary>
    /// <remarks>
    /// **Security:** Only accessible by users with the `Follower` or `Admin` role.
    /// Warning: This performs a hard delete in the PostgreSQL database.
    /// </remarks>
    /// <param name="id">The unique Guid of the Memory Content to delete.</param>
    /// <response code="204">Successfully deleted. No content returned.</response>
    /// <response code="403">If a Patient attempts to call this endpoint (Forbidden).</response>
    /// <response code="404">If the memory content ID does not exist.</response>
    [Authorize(Roles = "Follower,Admin")]
    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
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