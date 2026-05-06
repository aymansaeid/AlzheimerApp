using AlzheimerApp.Application.DTOs.MedicineLogs;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IMedicineLogService
{
    Task<List<MedicineLogResponse>> GetDailyLogsAsync(Guid patientId, DateTime date);
    Task UpdateLogStatusAsync(Guid logId, UpdateLogStatusRequest request);
    Task MarkOverdueLogsAsMissedAsync();
}