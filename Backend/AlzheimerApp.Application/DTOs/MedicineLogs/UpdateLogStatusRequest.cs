using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.DTOs.MedicineLogs;

public class UpdateLogStatusRequest
{
    public MedicineStatus Status { get; set; } // e.g., 1 for "Taken"
    public string? Note { get; set; }
}