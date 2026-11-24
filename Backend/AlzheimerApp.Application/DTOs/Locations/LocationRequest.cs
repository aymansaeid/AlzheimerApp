namespace AlzheimerApp.Application.DTOs.Locations;

/// <summary>
/// A GPS sample sent by the patient's phone to <c>POST /api/Location/log</c>.
/// The patient is identified from the JWT token, so no patient ID is sent.
/// </summary>
public class LocationRequest
{
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public float AccuracyMeters { get; set; }

    /// <summary>Optional. Phone battery level, 0–100.</summary>
    public int? BatteryLevel { get; set; }

    /// <summary>Optional. Whether the phone is currently charging.</summary>
    public bool? IsCharging { get; set; }
}