using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.DTOs.SafeZones;

/// <summary>A safe zone (circle on the map). Returned by the SafeZone endpoints and inside <c>GET /api/Location/patients/latest</c>.</summary>
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

    public static SafeZoneResponse FromEntity(SafeZone zone) => new()
    {
        Id = zone.Id,
        PatientId = zone.PatientId,
        Name = zone.Name,
        CenterLat = zone.CenterLat,
        CenterLng = zone.CenterLng,
        RadiusMeters = zone.RadiusMeters,
        IsActive = zone.IsActive,
        CreatedAt = zone.CreatedAt
    };
}