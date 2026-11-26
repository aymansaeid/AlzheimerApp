using AlzheimerApp.Application.Common;
using AlzheimerApp.Application.DTOs.MedicineLogs;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.Services;

public class MedicineLogService : IMedicineLogService
{
    // FCM data "type" values the Flutter app (notification_service.dart) switches on.
    public const string PushTypeMedicationMissed = "MEDICATION_MISSED";
    public const string PushTypeMedicationReminder = "MEDICATION_REMINDER";

    private readonly IMedicineLogRepository _logRepository;
    private readonly IMedicineRepository _medicineRepository;
    private readonly IPatientFollowerRepository _followerRepository;
    private readonly IAlertHistoryRepository _alertRepository;
    private readonly INotificationService _notificationService;
    private readonly IMedicineScheduleSettings _settings;
    private readonly TimeProvider _clock;

    public MedicineLogService(
        IMedicineLogRepository logRepository,
        IMedicineRepository medicineRepository,
        IPatientFollowerRepository followerRepository,
        IAlertHistoryRepository alertRepository,
        INotificationService notificationService,
        IMedicineScheduleSettings settings,
        TimeProvider clock)
    {
        _logRepository = logRepository;
        _medicineRepository = medicineRepository;
        _followerRepository = followerRepository;
        _alertRepository = alertRepository;
        _notificationService = notificationService;
        _settings = settings;
        _clock = clock;
    }

    private DateTime UtcNow => _clock.GetUtcNow().UtcDateTime;
    private TimeZoneInfo Tz => _settings.TimeZone;

    // ------------------------------------------------------------------ daily list (JIT)

    public async Task<List<MedicineLogResponse>> GetDailyLogsAsync(Guid patientId, DateTime date)
    {
        var localDate = ScheduleCalendar.ResolveLocalDate(date, Tz);
        var (fromUtc, toUtc) = ScheduleCalendar.LocalDayRangeUtc(localDate, Tz);
        await MarkOverdueLogsAsMissedAsync(patientId);

        // 1. O gün (Türkiye saatiyle) için HALİHAZIRDA var olan loglar
        var existingLogs = await _logRepository.GetLogsByPatientInRangeAsync(patientId, fromUtc, toUtc);

        // 2. JIT: o gün içilmesi gereken ama logu OLMAYAN ilaçlar için log üret
        var activeMeds = await _medicineRepository.GetActiveMedicinesByPatientIdAsync(patientId);
        var created = await CreateMissingLogsAsync(activeMeds, localDate, existingLogs);

        if (created > 0)
        {
            // Re-read so concurrent inserts (worker) are included exactly once, with Medicine loaded.
            existingLogs = await _logRepository.GetLogsByPatientInRangeAsync(patientId, fromUtc, toUtc);
        }

        // 3. Frontend'e gönder (ScheduledAt UTC'dir; uygulama yerel saate çevirir)
        return existingLogs
            .OrderBy(l => l.ScheduledAt)
            .Select(l => new MedicineLogResponse
            {
                Id = l.Id,
                MedicineId = l.MedicineId,
                MedicineName = l.Medicine?.Name ?? "Unknown Medicine",
                Dosage = l.Medicine?.Dosage ?? "",
                Instructions = l.Medicine?.Instructions,
                Status = l.Status,
                ScheduledAt = l.ScheduledAt,
                TakenAt = l.TakenAt,
                Note = l.Note
            }).ToList();
    }

    public async Task UpdateLogStatusAsync(Guid logId, UpdateLogStatusRequest request)
    {
        var log = await _logRepository.GetByIdAsync(logId);
        if (log == null) throw new Exception("Medicine log not found.");

        log.Status = request.Status;
        log.Note = request.Note;
        log.TakenAt = request.Status == MedicineStatus.Taken ? UtcNow : null;

        await _logRepository.UpdateAsync(log);
    }

    // ------------------------------------------------------------------ generation

    public async Task<int> GenerateLogsForTodayAsync()
    {
        var localToday = ScheduleCalendar.LocalDate(UtcNow, Tz);
        var (fromUtc, toUtc) = ScheduleCalendar.LocalDayRangeUtc(localToday, Tz);

        var allActiveMeds = await _medicineRepository.GetAllActiveMedicinesAsync();
        var existingLogs = await _logRepository.GetLogsInRangeAsync(fromUtc, toUtc);

        return await CreateMissingLogsAsync(allActiveMeds, localToday, existingLogs);
    }

    public async Task EnsureTodayLogsForPatientAsync(Guid patientId)
    {
        var now = UtcNow;
        var localToday = ScheduleCalendar.LocalDate(now, Tz);
        var (fromUtc, toUtc) = ScheduleCalendar.LocalDayRangeUtc(localToday, Tz);

        var meds = await _medicineRepository.GetActiveMedicinesByPatientIdAsync(patientId);
        var existingLogs = await _logRepository.GetLogsByPatientInRangeAsync(patientId, fromUtc, toUtc);

        // Called right after a medicine is added/edited: only doses still ahead today, never "already missed" ones.
        await CreateMissingLogsAsync(meds, localToday, existingLogs, notBeforeUtc: now);
    }

    /// <summary>One log per medicine per schedule time per local day; already-existing doses are skipped.</summary>
    private async Task<int> CreateMissingLogsAsync(
        IEnumerable<Medicine> meds, DateOnly localDate, IEnumerable<MedicineLog> existingLogs, DateTime? notBeforeUtc = null)
    {
        var existing = existingLogs.Select(l => (l.MedicineId, l.ScheduledAt)).ToHashSet();

        var newLogs = new List<MedicineLog>();
        foreach (var med in meds)
        {
            foreach (var dueUtc in ScheduleCalendar.DoseTimesUtc(med, localDate, Tz))
            {
                if (notBeforeUtc.HasValue && dueUtc < notBeforeUtc.Value) continue;
                if (existing.Contains((med.Id, dueUtc))) continue;

                newLogs.Add(new MedicineLog
                {
                    MedicineId = med.Id,
                    PatientId = med.PatientId,
                    Status = MedicineStatus.Pending,
                    ScheduledAt = dueUtc
                });
            }
        }

        var inserted = await _logRepository.AddRangeIgnoringDuplicatesAsync(newLogs);
        return inserted.Count;
    }

    // ------------------------------------------------------------------ reminder to the patient (+15 min)

    public async Task<int> SendDueRemindersAsync()
    {
        var now = UtcNow;
        var dueLogs = await _logRepository.GetPendingWithoutReminderAsync(now - _settings.ReminderDelay);
        if (dueLogs.Count == 0) return 0;

        // Mark first, so a crash or FCM error can never cause the same reminder to be sent twice.
        foreach (var log in dueLogs) log.IsAlarmSent = true;
        await _logRepository.SaveChangesAsync();

        int sent = 0;
        foreach (var log in dueLogs)
        {
            // Too old (server was asleep, or the dose was created late): skip silently instead of a stale push.
            if (now - (log.ScheduledAt + _settings.ReminderDelay) > _settings.NotificationWindow) continue;

            var token = log.Patient?.FcmToken;
            if (string.IsNullOrWhiteSpace(token)) continue;

            var medicineName = log.Medicine?.Name ?? "İlacınız";
            var dosage = string.IsNullOrWhiteSpace(log.Medicine?.Dosage) ? "" : $" ({log.Medicine!.Dosage})";
            var time = ScheduleCalendar.FormatLocalTime(log.ScheduledAt, Tz);

            await _notificationService.SendMulticastAsync(
                new List<string> { token },
                "💊 İlacınızı aldınız mı?",
                $"Saat {time} {medicineName}{dosage} dozunuz bekliyor. Aldıysanız uygulamadan işaretleyin.",
                new Dictionary<string, string>
                {
                    ["type"] = PushTypeMedicationReminder,
                    ["alertType"] = AlertType.MedicineReminder.ToString(),
                    ["patientId"] = log.PatientId.ToString(),
                    ["medicineLogId"] = log.Id.ToString(),
                    ["medicineName"] = medicineName,
                    ["scheduledTime"] = time
                });
            sent++;
        }

        return sent;
    }

    // ------------------------------------------------------------------ missed → care team (+60 min)

    public async Task<int> MarkOverdueLogsAsMissedAsync(Guid? patientId = null)
    {
        var now = UtcNow;
        var overdueLogs = await _logRepository.GetPendingLogsBeforeAsync(now - _settings.MissedAfter, patientId);
        if (overdueLogs.Count == 0) return 0;

        // 1. Status change first: Pending → Missed happens once, so the alert below is sent at most once.
        foreach (var log in overdueLogs)
        {
            log.Status = MedicineStatus.Missed;
            log.Note = "System Auto-Update: Patient did not confirm taking this medication.";
        }
        await _logRepository.SaveChangesAsync();

        // 2. Alert only recent ones; doses found long after the fact are just recorded as Missed.
        var toAlert = overdueLogs
            .Where(l => now - (l.ScheduledAt + _settings.MissedAfter) <= _settings.NotificationWindow)
            .GroupBy(l => l.PatientId);

        foreach (var patientLogs in toAlert)
        {
            var followers = await _followerRepository.GetFollowersByPatientIdAsync(patientLogs.Key);
            var tokens = followers
                .Where(f => f.Follower != null && !string.IsNullOrEmpty(f.Follower.FcmToken))
                .Select(f => f.Follower!.FcmToken!)
                .ToList();

            foreach (var log in patientLogs)
            {
                var patientName = log.Patient?.FullName ?? "Hasta";
                var medicineName = log.Medicine?.Name ?? "ilacını";
                var time = ScheduleCalendar.FormatLocalTime(log.ScheduledAt, Tz);
                var message = $"{patientName}, saat {time} {medicineName} dozunu almadı.";

                await _alertRepository.AddAsync(new AlertHistory
                {
                    PatientId = log.PatientId,
                    AlertType = AlertType.MedicineMissed,
                    Message = message,
                    IsRead = false,
                    SentAt = now
                });

                if (tokens.Count == 0) continue;

                await _notificationService.SendMulticastAsync(
                    tokens,
                    "💊 İlaç alınmadı",
                    message,
                    new Dictionary<string, string>
                    {
                        ["type"] = PushTypeMedicationMissed,
                        ["alertType"] = AlertType.MedicineMissed.ToString(),
                        ["patientId"] = log.PatientId.ToString(),
                        ["patientName"] = patientName,
                        ["medicineLogId"] = log.Id.ToString(),
                        ["medicineName"] = medicineName,
                        ["scheduledTime"] = time
                    });
            }
        }

        return overdueLogs.Count;
    }
}