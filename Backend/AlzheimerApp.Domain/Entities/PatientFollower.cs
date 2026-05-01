namespace AlzheimerApp.Domain.Entities;

public class PatientFollower
{
    public Guid Id { get; set; }

    public Guid FollowerId { get; set; }
    public User? Follower { get; set; }

    public Guid PatientId { get; set; }
    public User? Patient { get; set; }

    public string Relationship { get; set; } = string.Empty;
    public bool IsPrimary { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}