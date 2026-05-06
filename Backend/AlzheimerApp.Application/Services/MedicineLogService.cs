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
        var logs = await _logRepository.GetLogsByPatientAndDateAsync(patientId, date);

        // 👉 LAZY SMART-GENERATION LOGIC
        // If no logs exist for today, check if they have medicines scheduled for this day of the week!
        if (!logs.Any())
        {
            var activeMeds = await _medicineRepository.GetActiveMedicinesByPatientIdAsync(patientId);

            // C# DayOfWeek ranges from 0 (Sunday) to 6 (Saturday). We convert it to a string.
            string currentDayNum = ((int)date.DayOfWeek).ToString();

            // Find medicines where "DaysOfWeek" (e.g., "1,3,5") contains today's number
            var medsForToday = activeMeds.Where(m => m.DaysOfWeek.Contains(currentDayNum)).ToList();

            if (medsForToday.Any())
            {
                var newLogs = new List<MedicineLog>();

                foreach (var med in medsForToday)
                {
                    newLogs.Add(new MedicineLog
                    {
                        MedicineId = med.Id,
                        PatientId = patientId,
                        Status = MedicineStatus.Pending,
                        // Combine today's Date with the Medicine's specific Time
                        ScheduledAt = date.Date.Add(med.ScheduleTime),
                        Medicine = med // Attach for the mapping below
                    });
                }

                await _logRepository.AddRangeAsync(newLogs);
                logs = newLogs; // Return the newly generated logs
            }
        }

        return logs.Select(l => new MedicineLogResponse
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
}