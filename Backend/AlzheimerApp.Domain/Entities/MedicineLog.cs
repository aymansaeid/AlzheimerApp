using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Domain.Entities;

public class MedicineLog
{
    public Guid Id { get; set; }

    public Guid MedicineId { get; set; }
    public Medicine? Medicine { get; set; }

    public Guid PatientId { get; set; }
    public User? Patient { get; set; }

    public MedicineStatus Status { get; set; }
    public DateTime ScheduledAt { get; set; }
    public DateTime? TakenAt { get; set; }
    public string? Note { get; set; }
    public bool IsAlarmSent { get; set; } = false; 
}