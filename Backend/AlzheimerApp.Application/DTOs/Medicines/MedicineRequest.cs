namespace AlzheimerApp.Application.DTOs.Medicines;

public class MedicineRequest
{
    public Guid PatientId { get; set; }
    public Guid CreatorId { get; set; } // The Follower who is adding the medicine
    public string Name { get; set; } = string.Empty;
    public string Dosage { get; set; } = string.Empty;
    public string? Instructions { get; set; }
    public TimeSpan ScheduleTime { get; set; } // e.g., "08:30:00"
    public string DaysOfWeek { get; set; } = string.Empty; // e.g., "1,2,3,4,5,6,7" for every day
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
}