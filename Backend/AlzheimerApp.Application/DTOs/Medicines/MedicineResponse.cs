namespace AlzheimerApp.Application.DTOs.Medicines;

public class MedicineResponse
{
    public Guid Id { get; set; }
    public Guid PatientId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Dosage { get; set; } = string.Empty;
    public string? Instructions { get; set; }
    public TimeSpan ScheduleTime { get; set; }
    public string DaysOfWeek { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}