namespace AlzheimerApp.Application.DTOs.SafeZones;

public class SafeZoneResponse
{
    public Guid Id { get; set; }
    public Guid PatientId { get; set; }
    public string Name { get; set; } = string.Empty;
    public double CenterLat { get; set; }
    public double CenterLng { get; set; }
    public int RadiusMeters { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}