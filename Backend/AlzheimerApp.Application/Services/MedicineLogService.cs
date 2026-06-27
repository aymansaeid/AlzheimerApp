using AlzheimerApp.Application.DTOs.MedicineLogs;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.Services;

public class MedicineLogService : IMedicineLogService
{
    private readonly IMedicineLogRepository _logRepository;
    private readonly IMedicineRepository _medicineRepository;

    public MedicineLogService(IMedicineLogRepository logRepository, IMedicineRepository medicineRepository)
    {
        _logRepository = logRepository;
        _medicineRepository = medicineRepository;
    }

    public async Task<List<MedicineLogResponse>> GetDailyLogsAsync(Guid patientId, DateTime date)
    {
        // 1. O gün için veritabanında HALİHAZIRDA var olan logları getir
        var existingLogs = await _logRepository.GetLogsByPatientAndDateAsync(patientId, date);

        // 2. Hastanın aktif olan tüm ilaçlarını getir
        var activeMeds = await _medicineRepository.GetActiveMedicinesByPatientIdAsync(patientId);

        // C# DayOfWeek 0 (Pazar) ile 6 (Cumartesi) arasıdır. string'e çeviriyoruz.
        string currentDayNum = ((int)date.DayOfWeek).ToString();

        // 3. SADECE bugün içilmesi gereken ilaçları filtrele
        var medsForToday = activeMeds.Where(m => m.DaysOfWeek.Contains(currentDayNum)).ToList();

        // 4. JIT LOGIC DÜZELTMESİ: Bugün içilmesi gereken ama loglarda OLMAYAN ilaçları bul
        var existingLogMedicineIds = existingLogs.Select(l => l.MedicineId).ToHashSet();
        var missingMeds = medsForToday.Where(m => !existingLogMedicineIds.Contains(m.Id)).ToList();

        // 5. Eğer eksik ilaç varsa, SADECE onları üret
        if (missingMeds.Any())
        {
            var newLogs = new List<MedicineLog>();

            foreach (var med in missingMeds)
            {
                newLogs.Add(new MedicineLog
                {
                    MedicineId = med.Id,
                    PatientId = patientId,
                    Status = MedicineStatus.Pending,
                    ScheduledAt = date.Date.Add(med.ScheduleTime),
                    Medicine = med // Aşağıdaki mapleme için referansı ekle
                });
            }

            // Yeni üretilenleri veritabanına kaydet
            await _logRepository.AddRangeAsync(newLogs);

            // Mevcut listeye yeni üretilenleri de ekle ki ekrana hepsi gitsin
            existingLogs.AddRange(newLogs);
        }

        // 6. Artık existingLogs hem eskileri hem yenileri içeriyor, frontend'e gönder
        return existingLogs.Select(l => new MedicineLogResponse
        {
            Id = l.Id,
            MedicineId = l.MedicineId,
            MedicineName = l.Medicine?.Name ?? "Unknown Medicine",
            Dosage = l.Medicine?.Dosage ?? "",
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

        if (request.Status == MedicineStatus.Taken)
        {
            log.TakenAt = DateTime.UtcNow;
        }

        await _logRepository.UpdateAsync(log);
    }

    public async Task MarkOverdueLogsAsMissedAsync()
    {
        // "Missed" sayılması için ScheduledAt değerinin dünden önce olması gerekir
        var startOfToday = DateTime.UtcNow.Date;

        var overdueLogs = await _logRepository.GetPendingLogsBeforeAsync(startOfToday);

        if (!overdueLogs.Any()) return; // Güncellenecek bir şey yok

        foreach (var log in overdueLogs)
        {
            log.Status = MedicineStatus.Missed;
            log.Note = "System Auto-Update: Patient did not confirm taking this medication.";
        }

        // Değişiklikleri PostgreSQL'e tek seferde kaydet
        await _logRepository.UpdateRangeAsync(overdueLogs);
    }
}