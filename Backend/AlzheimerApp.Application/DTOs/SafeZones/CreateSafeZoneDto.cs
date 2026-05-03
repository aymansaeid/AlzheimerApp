namespace AlzheimerApp.Application.DTOs.SafeZones;

public class CreateSafeZoneDto
{
    public Guid PatientId { get; set; }
    public string Name { get; set; } = string.Empty;
    public double CenterLat { get; set; }
    public double CenterLng { get; set; }
    public int RadiusMeters { get; set; }
}