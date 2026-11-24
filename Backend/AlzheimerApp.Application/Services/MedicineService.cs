using AlzheimerApp.Application.Common;
using AlzheimerApp.Application.DTOs.Medicines;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Services;

public class MedicineService : IMedicineService
{
    private readonly IMedicineRepository _medicineRepository;
    private readonly IMedicineLogRepository _logRepository;
    private readonly IMedicineLogService _logService;
    private readonly IMedicineScheduleSettings _settings;
    private readonly TimeProvider _clock;

    public MedicineService(
        IMedicineRepository medicineRepository,
        IMedicineLogRepository logRepository,
        IMedicineLogService logService,
        IMedicineScheduleSettings settings,
        TimeProvider clock)
    {
        _medicineRepository = medicineRepository;
        _logRepository = logRepository;
        _logService = logService;
        _settings = settings;
        _clock = clock;
    }

    public async Task<MedicineResponse> AddMedicineAsync(Guid creatorId, MedicineRequest request)
    {
        var medicine = new Medicine
        {
            PatientId = request.PatientId,
            CreatedBy = creatorId,
            IsActive = true,
            CreatedAt = _clock.GetUtcNow().UtcDateTime
        };
        Apply(medicine, request.Name, request.Dosage, request.Instructions,
              TimesOf(request.ScheduleTimes, request.ScheduleTime), request.DaysOfWeek, request.StartDate, request.EndDate);

        var savedEntity = await _medicineRepository.AddAsync(medicine);

        // Create today's upcoming doses right away, so reminders work even if nobody opens the app before midnight.
        await _logService.EnsureTodayLogsForPatientAsync(savedEntity.PatientId);

        return MapToResponse(savedEntity);
    }

    public async Task<List<MedicineResponse>> GetPatientMedicinesAsync(Guid patientId)
    {
        var medicines = await _medicineRepository.GetActiveMedicinesByPatientIdAsync(patientId);
        return medicines.Select(MapToResponse).ToList();
    }

    public async Task<MedicineResponse> GetMedicineAsync(Guid id)
    {
        var medicine = await _medicineRepository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException("Medicine not found.");
        return MapToResponse(medicine);
    }

    public async Task<MedicineResponse> UpdateMedicineAsync(Guid id, UpdateMedicineRequest request)
    {
        var medicine = await _medicineRepository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException("Medicine not found.");

        Apply(medicine, request.Name, request.Dosage, request.Instructions,
              TimesOf(request.ScheduleTimes, request.ScheduleTime), request.DaysOfWeek, request.StartDate, request.EndDate);
        medicine.IsActive = request.IsActive;

        await _medicineRepository.UpdateAsync(medicine);

        // Drop pending doses (today and later) that no longer match the new schedule, e.g. a removed 14:00 time.
        // Doses that still match are kept as they are (same id); taken/missed history is never touched.
        await RemoveStalePendingDosesAsync(medicine);

        // Add today's doses for new times that are still ahead.
        await _logService.EnsureTodayLogsForPatientAsync(medicine.PatientId);

        return MapToResponse(medicine);
    }

    public async Task DeleteMedicineAsync(Guid id)
    {
        var medicine = await _medicineRepository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException("Medicine not found.");

        var futureLogs = await _logRepository.GetFuturePendingLogsByMedicineIdAsync(id, _clock.GetUtcNow().UtcDateTime);
        if (futureLogs.Any())
        {
            await _logRepository.RemoveRangeAsync(futureLogs);
        }

        await _medicineRepository.DeleteAsync(medicine);
    }

    // ------------------------------------------------------------------ helpers

    private async Task RemoveStalePendingDosesAsync(Medicine medicine)
    {
        var tz = _settings.TimeZone;
        var localToday = ScheduleCalendar.LocalDate(_clock.GetUtcNow().UtcDateTime, tz);
        var (todayStartUtc, _) = ScheduleCalendar.LocalDayRangeUtc(localToday, tz);

        var pending = await _logRepository.GetFuturePendingLogsByMedicineIdAsync(medicine.Id, todayStartUtc);

        var stale = pending.Where(log =>
        {
            var day = ScheduleCalendar.LocalDate(log.ScheduledAt, tz);
            return !ScheduleCalendar.DoseTimesUtc(medicine, day, tz, skipBeforeCreation: false).Contains(log.ScheduledAt);
        }).ToList();

        if (stale.Count > 0) await _logRepository.RemoveRangeAsync(stale);
    }

    private static IEnumerable<TimeSpan> TimesOf(List<TimeSpan>? scheduleTimes, TimeSpan? legacySingleTime) =>
        scheduleTimes is { Count: > 0 } ? scheduleTimes
        : legacySingleTime.HasValue ? new[] { legacySingleTime.Value }
        : Enumerable.Empty<TimeSpan>();

    private static void Apply(Medicine medicine, string name, string dosage, string? instructions,
        IEnumerable<TimeSpan> times, string daysOfWeek, DateTime startDate, DateTime? endDate)
    {
        if (string.IsNullOrWhiteSpace(name)) throw new ArgumentException("Medicine name is required.");
        if (endDate.HasValue && endDate.Value < startDate) throw new ArgumentException("endDate cannot be before startDate.");

        medicine.Name = name.Trim();
        medicine.Dosage = dosage?.Trim() ?? string.Empty;
        medicine.Instructions = string.IsNullOrWhiteSpace(instructions) ? null : instructions.Trim();
        medicine.ScheduleTimes = ScheduleCalendar.NormalizeScheduleTimes(times);
        medicine.DaysOfWeek = ScheduleCalendar.NormalizeDaysOfWeek(daysOfWeek);
        medicine.StartDate = AsUtc(startDate);
        medicine.EndDate = endDate.HasValue ? AsUtc(endDate.Value) : null;
    }

    // Npgsql only writes UTC DateTimes to timestamptz; a date sent without "Z" is taken as UTC.
    private static DateTime AsUtc(DateTime value) =>
        value.Kind == DateTimeKind.Unspecified ? DateTime.SpecifyKind(value, DateTimeKind.Utc) : value.ToUniversalTime();

    private static MedicineResponse MapToResponse(Medicine medicine)
    {
        var times = medicine.ScheduleTimes.OrderBy(t => t).ToList();
        return new MedicineResponse
        {
            Id = medicine.Id,
            PatientId = medicine.PatientId,
            CreatedBy = medicine.CreatedBy,
            Name = medicine.Name,
            Dosage = medicine.Dosage,
            Instructions = medicine.Instructions,
            ScheduleTimes = times,
            ScheduleTime = times.FirstOrDefault(),
            DaysOfWeek = medicine.DaysOfWeek,
            StartDate = medicine.StartDate,
            EndDate = medicine.EndDate,
            IsActive = medicine.IsActive,
            CreatedAt = medicine.CreatedAt
        };
    }
}