namespace AlzheimerApp.Application.DTOs.MemoryContents;

public class MemoryProfileResponse
{
    public string PersonName { get; set; } = string.Empty;
    public string Relationship { get; set; } = string.Empty;
    public Guid UploaderId { get; set; }
    public string? CoverPhotoUrl { get; set; }
    public int MemoryCount { get; set; }

    // WhatsApp Tarzı (En Son Ses Kaydı Bilgileri)
    public string? LatestVoiceRecordUrl { get; set; }
    public string? LatestVoiceRecordText { get; set; }
}