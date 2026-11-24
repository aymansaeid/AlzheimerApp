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

    /// <summary>
    /// Every time of day (local, e.g. 08:00 and 20:00 in Turkey) this medicine is taken. One medicine = one record,
    /// however many times a day it is taken. Stored as a PostgreSQL <c>interval[]</c>.
    /// </summary>
    public List<TimeSpan> ScheduleTimes { get; set; } = new();

    public string DaysOfWeek { get; set; } = string.Empty; // e.g., "1,3,5" for Mon, Wed, Fri

    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<MedicineLog> MedicineLogs { get; set; } = new List<MedicineLog>();
}