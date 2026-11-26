using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IMedicineLogRepository
{
    /// <summary>A patient's logs with <c>fromUtc &lt;= ScheduledAt &lt; toUtc</c>, Medicine included, ordered by time.</summary>
    Task<List<MedicineLog>> GetLogsByPatientInRangeAsync(Guid patientId, DateTime fromUtc, DateTime toUtc);

    /// <summary>All patients' logs with <c>fromUtc &lt;= ScheduledAt &lt; toUtc</c> (for the daily generator).</summary>
    Task<List<MedicineLog>> GetLogsInRangeAsync(DateTime fromUtc, DateTime toUtc);

    /// <summary>Pending logs due at or before <paramref name="scheduledBeforeUtc"/> whose patient reminder was not sent yet. Medicine + Patient included.</summary>
    Task<List<MedicineLog>> GetPendingWithoutReminderAsync(DateTime scheduledBeforeUtc);

    /// <summary>Pending logs due at or before <paramref name="cutoffUtc"/> (optionally one patient's). Medicine + Patient included.</summary>
    Task<List<MedicineLog>> GetPendingLogsBeforeAsync(DateTime cutoffUtc, Guid? patientId = null);

    Task<MedicineLog?> GetByIdAsync(Guid id);
    Task UpdateAsync(MedicineLog log);
    Task AddRangeAsync(IEnumerable<MedicineLog> logs);

    /// <summary>
    /// Inserts generated logs; a log that already exists (same MedicineId + ScheduledAt, unique index) is skipped
    /// instead of failing, so the daily worker and on-demand generation can safely race. Returns the inserted logs.
    /// </summary>
    Task<List<MedicineLog>> AddRangeIgnoringDuplicatesAsync(IReadOnlyCollection<MedicineLog> logs);
    Task UpdateRangeAsync(IEnumerable<MedicineLog> logs);

    /// <summary>
    /// Saves property changes on logs loaded by this repository (only the changed columns are written;
    /// included Patient/Medicine rows are not touched).
    /// </summary>
    Task SaveChangesAsync();
    Task<List<MedicineLog>> GetFuturePendingLogsByMedicineIdAsync(Guid medicineId, DateTime fromDate);
    Task RemoveRangeAsync(IEnumerable<MedicineLog> logs);
}