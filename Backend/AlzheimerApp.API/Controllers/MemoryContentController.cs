using AlzheimerApp.API.Extensions;
using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Application.DTOs.MemoryContents;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlzheimerApp.API.Controllers;

/// <summary>
/// Manages personalized memory content (photos, voice messages, identity cards) to help patients recognize their loved ones.
/// </summary>
/// <remarks>
/// **Permissions (per patient, see `permissions` in `/api/Follower/my-patients`):**
/// * View: the patient, any care team member, system admin.
/// * Add: any care team member (`canAddMemories`).
/// * Edit / delete: the uploader, or the primary caregiver (`canManageAllMemories`).
/// </remarks>
[Authorize]
[ApiController]
[Route("api/[controller]")]
public class MemoryContentController : ControllerBase
{
    private readonly IMemoryContentService _contentService;
    private readonly ICareTeamAccessService _access;
    private readonly ILogger<MemoryContentController> _logger;

    public MemoryContentController(IMemoryContentService contentService, ICareTeamAccessService access, ILogger<MemoryContentController> logger)
    {
        _contentService = contentService;
        _access = access;
        _logger = logger;
    }

    /// <summary>
    /// Adds a new memory (photo, voice memo, identity card) to the patient's profile.
    /// </summary>
    /// <remarks>
    /// **Security:** any member of the patient's care team. The uploader is taken from the JWT token.
    ///
    /// **Flow:** upload the file to Firebase Storage from the app, then send its download URL as `fileUrl`.
    /// `fileUrl` and `title` are **optional**: without a title, the person's name or the type ("Fotoğraf", "Ses kaydı",
    /// "Kimlik kartı") is used.
    ///
    /// **ContentType:** `0` = Photo, `1` = Voice, `2` = IdentityCard
    ///
    /// Sample request:
    ///
    ///     POST /api/MemoryContent
    ///     {
    ///        "patientId": "019ea1ef-4915-729d-b2cb-8d49f8b055ac",
    ///        "contentType": 1,
    ///        "title": null,
    ///        "description": "Bayramda torunlarla",
    ///        "fileUrl": "https://firebasestorage.googleapis.com/v0/b/...",
    ///        "personName": "Ayşe",
    ///        "relationship": "Kızı"
    ///     }
    /// </remarks>
    /// <response code="200">Created. Returns the memory with uploader name and photo.</response>
    /// <response code="400">If validation fails (e.g. unknown contentType).</response>
    /// <response code="403">If the caller is not in this patient's care team.</response>
    [HttpPost]
    [ProducesResponseType(typeof(MemoryContentResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> AddContent([FromBody] MemoryContentRequest request)
    {
        var permissions = await _access.GetPermissionsAsync(User, request.PatientId);
        if (!permissions.CanAddMemories) return this.NoPermission();

        return await Run(() => _contentService.AddContentAsync(User.GetUserId(), request));
    }

    /// <summary>
    /// Updates a memory. PARTIAL: send only the fields you change.
    /// </summary>
    /// <remarks>
    /// **Security:** the uploader, or the primary caregiver.
    ///
    /// Omitted / null fields keep their value (so a voice memo never turns into a photo and its file is never lost
    /// by accident). Send `""` to clear `description`, `fileUrl`, `personName` or `relationship`.
    /// Set `isActive: false` to hide a memory without deleting it.
    ///
    ///     PUT /api/MemoryContent/{id}
    ///     { "title": "Bayram 2019", "relationship": "Kızı" }
    /// </remarks>
    /// <param name="id">The unique Guid of the Memory Content to update.</param>
    /// <param name="request">Only the fields to change.</param>
    /// <response code="200">Updated. Returns the memory as saved.</response>
    /// <response code="403">If the caller may not edit this memory.</response>
    /// <response code="404">If the memory content ID does not exist.</response>
    [HttpPut("{id}")]
    [ProducesResponseType(typeof(MemoryContentResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateContent(Guid id, [FromBody] UpdateMemoryContentRequest request)
    {
        var check = await CheckCanModifyAsync(id);
        if (check != null) return check;

        return await Run(() => _contentService.UpdateContentAsync(id, request));
    }

    /// <summary>
    /// Permanently deletes a memory.
    /// </summary>
    /// <remarks>
    /// **Security:** the uploader, or the primary caregiver.
    /// </remarks>
    /// <param name="id">The unique Guid of the Memory Content to delete.</param>
    /// <response code="204">Successfully deleted. No content returned.</response>
    /// <response code="403">If the caller may not delete this memory.</response>
    /// <response code="404">If the memory content ID does not exist.</response>
    [HttpDelete("{id}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteContent(Guid id)
    {
        var check = await CheckCanModifyAsync(id);
        if (check != null) return check;

        try
        {
            await _contentService.DeleteContentAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to delete memory {MemoryId}.", id);
            return StatusCode(StatusCodes.Status500InternalServerError, new { Error = "The memory could not be deleted." });
        }
    }

    /// <summary>
    /// Retrieves the active memories of a patient, newest first, with optional filters.
    /// </summary>
    /// <remarks>
    /// **Security:** the patient, any care team member, or a system admin.
    ///
    /// **Filtering Examples:**
    /// * Get all photos: `/api/MemoryContent/patient/{patientId}?contentType=0`
    /// * Get everything related to a specific person: `/api/MemoryContent/patient/{patientId}?personName=Ahmet`
    /// * Filter by app user: `/api/MemoryContent/patient/{patientId}?uploaderId=1234...`
    ///
    /// Each item includes `uploaderId`, `uploaderName`, `uploaderProfilePhotoUrl` and `isActive`.
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <param name="uploaderId">Optional: only memories uploaded by this user.</param>
    /// <param name="personName">Optional: name search (case-insensitive).</param>
    /// <param name="contentType">Optional: 0 = Photo, 1 = Voice, 2 = IdentityCard.</param>
    /// <response code="200">Returns the memories.</response>
    /// <response code="403">If the caller may not see this patient.</response>
    [HttpGet("patient/{patientId}")]
    [ProducesResponseType(typeof(List<MemoryContentResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetPatientContent(
        Guid patientId,
        [FromQuery] Guid? uploaderId,
        [FromQuery] string? personName,
        [FromQuery] int? contentType)
    {
        if (!(await _access.GetPermissionsAsync(User, patientId)).CanView) return this.NoPermission();

        return await Run(() => _contentService.GetPatientContentAsync(patientId, uploaderId, personName, contentType));
    }

    /// <summary>
    /// Retrieves memories grouped by person (one card per person), paginated.
    /// </summary>
    /// <remarks>
    /// **Security:** the patient, any care team member, or a system admin.
    /// Each card includes `uploaderName` and `uploaderProfilePhotoUrl`.
    /// </remarks>
    /// <param name="patientId">The unique Guid of the Patient.</param>
    /// <param name="page">Page number, starting at 1.</param>
    /// <param name="pageSize">Cards per page (default 5).</param>
    /// <response code="200">Returns one page of person cards.</response>
    /// <response code="403">If the caller may not see this patient.</response>
    [HttpGet("patient/{patientId}/profiles")]
    [ProducesResponseType(typeof(PagedResponse<MemoryProfileResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public async Task<IActionResult> GetMemoryProfiles(
        Guid patientId,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 5)
    {
        if (!(await _access.GetPermissionsAsync(User, patientId)).CanView) return this.NoPermission();

        if (page < 1) page = 1;
        if (pageSize < 1) pageSize = 5;

        return await Run(() => _contentService.GetPaginatedMemoryProfilesAsync(patientId, page, pageSize));
    }

    /// <summary>Uploader or primary caregiver may modify; returns 404/403 result, or null when allowed.</summary>
    private async Task<IActionResult?> CheckCanModifyAsync(Guid memoryId)
    {
        var owner = await _access.GetMemoryOwnerAsync(memoryId);
        if (owner == null) return NotFound(new { Error = "Memory content not found." });

        var permissions = await _access.GetPermissionsAsync(User, owner.Value.PatientId);
        bool isOwnMemory = owner.Value.UploaderId == User.GetUserId();

        return permissions.CanManageAllMemories || (permissions.CanAddMemories && isOwnMemory)
            ? null
            : this.NoPermission("Only the uploader or the primary caregiver can change this memory.");
    }

    private async Task<IActionResult> Run<T>(Func<Task<T>> action)
    {
        try
        {
            return Ok(await action());
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { Error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Memory content request failed.");
            return StatusCode(StatusCodes.Status500InternalServerError, new { Error = "The request could not be completed. Please try again later." });
        }
    }
}