using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Domain.Entities;

public class MemoryContent
{
    public Guid Id { get; set; }

    public Guid PatientId { get; set; }
    public User? Patient { get; set; }

    public Guid UploadedBy { get; set; }
    public User? Uploader { get; set; }

    public MemoryContentType ContentType { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string FileUrl { get; set; } = string.Empty;
    public string? PersonName { get; set; }
    public string? Relationship { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}