namespace AlzheimerApp.Domain.Entities;

public class PatientInvite
{
    public Guid Id { get; set; }
    public Guid PatientId { get; set; }
    public string InviteCode { get; set; } = string.Empty;

    // If true, the person who clicks this link becomes the Master Admin (is_primary = true)
    // If false, they become a standard viewer (is_primary = false)
    public bool IsPrimaryInvite { get; set; }

    public DateTime ExpiresAt { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}