namespace AlzheimerApp.Application.DTOs.Locations;

public class LocationRequest
{
    public Guid PatientId { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public float AccuracyMeters { get; set; }
}