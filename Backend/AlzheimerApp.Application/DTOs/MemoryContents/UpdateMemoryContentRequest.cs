using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.DTOs.MemoryContents;

/// <summary>
/// Body of <c>PUT /api/MemoryContent/{id}</c>. PARTIAL update: only the fields you send are changed;
/// omitted / null fields keep their current value. Send an empty string to clear a text field
/// (description, fileUrl, personName, relationship).
/// </summary>
public class UpdateMemoryContentRequest
{
    public MemoryContentType? ContentType { get; set; }
    public string? Title { get; set; }
    public string? Description { get; set; }
    public string? FileUrl { get; set; }
    public string? PersonName { get; set; }
    public string? Relationship { get; set; }
    public bool? IsActive { get; set; }
}