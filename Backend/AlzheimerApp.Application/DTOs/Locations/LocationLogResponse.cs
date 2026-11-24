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

    /// <summary>Phone battery level (0–100), or null if the app did not send it.</summary>
    public int? BatteryLevel { get; set; }

    /// <summary>Whether the phone was charging, or null if unknown.</summary>
    public bool? IsCharging { get; set; }
}