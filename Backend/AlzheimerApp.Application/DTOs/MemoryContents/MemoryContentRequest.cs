using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.DTOs.MemoryContents;

public class MemoryContentRequest
{
    public Guid PatientId { get; set; }
    public Guid UploadedBy { get; set; } // The Follower who uploaded it
    public MemoryContentType ContentType { get; set; } // 0 = Photo, 1 = Voice, 2 = IdentityCard
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? FileUrl { get; set; } // Optional: URL from Firebase Storage (not every memory has a file)
    public string? PersonName { get; set; }
    public string? Relationship { get; set; }
}