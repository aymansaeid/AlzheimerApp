namespace AlzheimerApp.Application.DTOs.Medicines;

public class UpdateMedicineRequest
{
    public string Name { get; set; } = string.Empty;
    public string Dosage { get; set; } = string.Empty;
    public string? Instructions { get; set; }
    public TimeSpan ScheduleTime { get; set; }
    public string DaysOfWeek { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public bool IsActive { get; set; }
}