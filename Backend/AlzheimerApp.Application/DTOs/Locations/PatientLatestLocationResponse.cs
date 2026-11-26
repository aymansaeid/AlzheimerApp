namespace AlzheimerApp.Application.DTOs.Locations;

using AlzheimerApp.Application.DTOs.SafeZones;

/// <summary>
/// One entry of <c>GET /api/Location/patients/latest</c>: a patient and their most recent known position.
/// </summary>
public class PatientLatestLocationResponse
{
    public Guid PatientId { get; set; }
    public string FullName { get; set; } = string.Empty;

    /// <summary>The patient's profile photo URL, or null.</summary>
    public string? ProfilePhotoUrl { get; set; }

    /// <summary>The patient's phone number (for the "Ara" / call button), or null if not set.</summary>
    public string? Phone { get; set; }

    /// <summary>The most recent location record, or <c>null</c> if the patient has never sent a location.</summary>
    public LatestLocationResponse? LatestLocation { get; set; }

    /// <summary>The patient's ACTIVE safe zones (circles to draw on the map). Empty list if none.</summary>
    public List<SafeZoneResponse> SafeZones { get; set; } = new();
}

/// <summary>
/// A single location record, as used by <see cref="PatientLatestLocationResponse"/>.
/// </summary>
public class LatestLocationResponse
{
    public double Latitude { get; set; }
    public double Longitude { get; set; }

    /// <summary>When the location was recorded (UTC, ISO 8601).</summary>
    public DateTime Timestamp { get; set; }

    /// <summary>
    /// <c>false</c> if the patient was outside every active safe zone when this location was recorded.
    /// Patients with no active safe zone are always reported as <c>true</c>.
    /// </summary>
    public bool IsInsideSafeZone { get; set; }

    /// <summary>Phone battery level (0–100) at that moment, or null if the app did not send it.</summary>
    public int? BatteryLevel { get; set; }

    /// <summary>Whether the phone was charging at that moment, or null if unknown.</summary>
    public bool? IsCharging { get; set; }
}