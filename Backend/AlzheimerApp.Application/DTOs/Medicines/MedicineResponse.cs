namespace AlzheimerApp.Application.DTOs.Medicines;

public class MedicineResponse
{
    public Guid Id { get; set; }
    public Guid PatientId { get; set; }
    public Guid CreatedBy { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Dosage { get; set; } = string.Empty;
    public string? Instructions { get; set; }

    /// <summary>All daily times, sorted, in local (Turkey) time: ["08:00:00", "20:00:00"].</summary>
    public List<TimeSpan> ScheduleTimes { get; set; } = new();

    /// <summary>Deprecated: the first of <see cref="ScheduleTimes"/>, kept so old app versions keep working.</summary>
    public TimeSpan ScheduleTime { get; set; }

    /// <summary>Normalized weekday list, e.g. "1,3,5" (0 = Sunday).</summary>
    public string DaysOfWeek { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}