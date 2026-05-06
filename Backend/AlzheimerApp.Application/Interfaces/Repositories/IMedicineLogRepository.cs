using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IMedicineLogRepository
{
    Task<List<MedicineLog>> GetLogsByPatientAndDateAsync(Guid patientId, DateTime date);
    Task<MedicineLog?> GetByIdAsync(Guid id);
    Task UpdateAsync(MedicineLog log);
    Task AddRangeAsync(IEnumerable<MedicineLog> logs); // For bulk generation
    Task<List<MedicineLog>> GetPendingLogsBeforeAsync(DateTime cutoffDate);
    Task UpdateRangeAsync(IEnumerable<MedicineLog> logs);
}