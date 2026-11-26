using AlzheimerApp.Application.DTOs.MedicineLogs;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IMedicineLogService
{
    /// <summary>
    /// A patient's doses for one local (Turkey) calendar day, generating missing Pending logs on the fly.
    /// <paramref name="date"/>: a route date like 2026-11-24 is taken as that local day; a UTC instant
    /// (e.g. <c>DateTime.UtcNow</c>) is converted to the local day first.
    /// </summary>
    Task<List<MedicineLogResponse>> GetDailyLogsAsync(Guid patientId, DateTime date);

    Task UpdateLogStatusAsync(Guid logId, UpdateLogStatusRequest request);

    /// <summary>Creates today's (local) Pending logs for every active medicine of every patient. Returns how many were created.</summary>
    Task<int> GenerateLogsForTodayAsync();

    /// <summary>Creates today's (local) Pending logs for one patient's medicines (after a medicine is added or changed).</summary>
    Task EnsureTodayLogsForPatientAsync(Guid patientId);

    /// <summary>
    /// Sends the patient a "did you take it?" push for doses still Pending <c>ReminderDelay</c> after their time.
    /// Each dose is reminded at most once. Returns the number of reminders sent.
    /// </summary>
    Task<int> SendDueRemindersAsync();

    /// <summary>
    /// Marks doses still Pending <c>MissedAfter</c> after their time as Missed, records a MedicineMissed alert and
    /// push-notifies the care team (<c>type = MEDICATION_MISSED</c>). Returns the number of doses marked missed.
    /// <paramref name="patientId"/> limits it to one patient (used before returning a daily list).
    /// </summary>
    Task<int> MarkOverdueLogsAsMissedAsync(Guid? patientId = null);
}