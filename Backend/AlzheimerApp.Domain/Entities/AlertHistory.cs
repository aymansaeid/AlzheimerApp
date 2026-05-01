using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Domain.Entities;

public class AlertHistory
{
    public Guid Id { get; set; }

    public Guid PatientId { get; set; }
    public User? Patient { get; set; }

    public AlertType AlertType { get; set; }
    public string Message { get; set; } = string.Empty;
    public bool IsRead { get; set; }
    public DateTime SentAt { get; set; } = DateTime.UtcNow;
}