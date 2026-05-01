namespace AlzheimerApp.Domain.Entities;

public class SafeZone
{
    public Guid Id { get; set; }

    public Guid PatientId { get; set; }
    public User? Patient { get; set; }

    public string Name { get; set; } = string.Empty;
    public double CenterLat { get; set; }
    public double CenterLng { get; set; }
    public int RadiusMeters { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}