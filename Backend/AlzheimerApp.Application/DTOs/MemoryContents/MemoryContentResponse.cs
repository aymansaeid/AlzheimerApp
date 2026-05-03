using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.DTOs.MemoryContents;

public class MemoryContentResponse
{
    public Guid Id { get; set; }
    public Guid PatientId { get; set; }
    public MemoryContentType ContentType { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string FileUrl { get; set; } = string.Empty;
    public string? PersonName { get; set; }
    public string? Relationship { get; set; }
    public DateTime CreatedAt { get; set; }
}