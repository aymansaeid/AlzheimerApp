namespace AlzheimerApp.Application.DTOs.SafeZones;

public class UpdateSafeZoneRequest
{
    public string Name { get; set; } = string.Empty;
    public double CenterLat { get; set; }
    public double CenterLng { get; set; }
    public int RadiusMeters { get; set; }
    public bool IsActive { get; set; }
}