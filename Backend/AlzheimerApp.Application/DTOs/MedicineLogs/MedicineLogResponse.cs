using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.DTOs.MedicineLogs;

public class MedicineLogResponse
{
    public Guid Id { get; set; }
    public Guid MedicineId { get; set; }
    public string MedicineName { get; set; } = string.Empty;
    public string Dosage { get; set; } = string.Empty;
    public string? Instructions { get; set; }
    public MedicineStatus Status { get; set; } // Pending, Taken, or Missed
    public DateTime ScheduledAt { get; set; }
    public DateTime? TakenAt { get; set; }
    public string? Note { get; set; }
}