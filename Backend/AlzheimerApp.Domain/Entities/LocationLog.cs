namespace AlzheimerApp.Domain.Entities;

public class LocationLog
{
    public Guid Id { get; set; }

    public Guid PatientId { get; set; }
    public User? Patient { get; set; }

    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public float AccuracyMeters { get; set; }
    public DateTime RecordedAt { get; set; } = DateTime.UtcNow;
    public bool IsOutsideZone { get; set; }
    public bool AlertSent { get; set; }
}