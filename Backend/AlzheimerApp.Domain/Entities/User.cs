using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Domain.Entities;

public class User
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public UserRole Role { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string? AvatarUrl { get; set; }
    public string? FcmToken { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation Properties
    public ICollection<PatientFollower> FollowedPatients { get; set; } = new List<PatientFollower>();
    public ICollection<PatientFollower> Followers { get; set; } = new List<PatientFollower>();
    public ICollection<SafeZone> SafeZones { get; set; } = new List<SafeZone>();
    public ICollection<LocationLog> LocationLogs { get; set; } = new List<LocationLog>();
    public ICollection<MemoryContent> MemoryContents { get; set; } = new List<MemoryContent>();
    public ICollection<Medicine> Medicines { get; set; } = new List<Medicine>();
    public ICollection<AlertHistory> Alerts { get; set; } = new List<AlertHistory>();
}