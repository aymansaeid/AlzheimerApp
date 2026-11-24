namespace AlzheimerApp.Application.DTOs.Locations;

public class LocationLogResponse
{
    public Guid PatientId { get; set; }
    public string? ProfilePhotoUrl { get; set; } 
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public double AccuracyMeters { get; set; }
    public DateTime RecordedAt { get; set; }
    public bool IsOutsideZone { get; set; }
}