using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.DTOs.MemoryContents;

public class MemoryContentRequest
{
    public Guid PatientId { get; set; }
    public Guid UploadedBy { get; set; } // The Follower who uploaded it
    public MemoryContentType ContentType { get; set; } // 0 = Photo, 1 = Voice, 2 = IdentityCard
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string FileUrl { get; set; } = string.Empty; // URL from Firebase Storage
    public string? PersonName { get; set; }
    public string? Relationship { get; set; }
}