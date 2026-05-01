namespace AlzheimerApp.Domain.Entities;

public class Medicine
{
    public Guid Id { get; set; }

    public Guid PatientId { get; set; }
    public User? Patient { get; set; }

    public Guid CreatedBy { get; set; }
    public User? Creator { get; set; }

    public string Name { get; set; } = string.Empty;
    public string Dosage { get; set; } = string.Empty;
    public string? Instructions { get; set; }

    public TimeSpan ScheduleTime { get; set; }
    public string DaysOfWeek { get; set; } = string.Empty; // e.g., "1,3,5" for Mon, Wed, Fri

    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<MedicineLog> MedicineLogs { get; set; } = new List<MedicineLog>();
}