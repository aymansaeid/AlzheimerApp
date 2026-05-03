namespace AlzheimerApp.Application.DTOs.Followers;

public class FollowerResponse
{
    public Guid Id { get; set; }
    public Guid PatientId { get; set; }
    public Guid FollowerId { get; set; }
    public string Relationship { get; set; } = string.Empty;
    public bool IsPrimary { get; set; }
    public DateTime CreatedAt { get; set; }
}