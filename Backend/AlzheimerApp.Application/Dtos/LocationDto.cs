namespace AlzheimerApp.Application.DTOs;

public class LocationDto
{
    public Guid PatientId { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public float AccuracyMeters { get; set; }
}