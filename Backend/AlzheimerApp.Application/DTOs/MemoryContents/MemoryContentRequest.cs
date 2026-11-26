using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.DTOs.MemoryContents;

/// <summary>
/// Body of <c>POST /api/MemoryContent</c>. The uploader is taken from the JWT token
/// (an <c>uploadedBy</c> / <c>uploaderId</c> sent by the app is ignored).
/// </summary>
public class MemoryContentRequest
{
    public Guid PatientId { get; set; }
    public MemoryContentType ContentType { get; set; } // 0 = Photo, 1 = Voice, 2 = IdentityCard

    /// <summary>Optional. If empty, the person's name or the content type ("Fotoğraf", "Ses kaydı"...) is used.</summary>
    public string? Title { get; set; }

    public string? Description { get; set; }
    public string? FileUrl { get; set; } // Optional: URL from Firebase Storage (not every memory has a file)
    public string? PersonName { get; set; }
    public string? Relationship { get; set; }
}