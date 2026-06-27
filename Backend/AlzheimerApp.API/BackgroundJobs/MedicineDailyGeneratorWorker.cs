using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.API.BackgroundJobs;

public class MedicineDailyGeneratorWorker : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<MedicineDailyGeneratorWorker> _logger;

    public MedicineDailyGeneratorWorker(IServiceScopeFactory scopeFactory, ILogger<MedicineDailyGeneratorWorker> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Midnight Sweeper is starting up...");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await GenerateGlobalLogsForTodayAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "CRITICAL ERROR: Midnight Sweeper failed to generate logs.");
            }

            var now = DateTime.UtcNow;
            var nextRunTime = now.Date.AddDays(1).AddMinutes(1);
            var delay = nextRunTime - now;

            _logger.LogInformation($"Midnight Sweeper sleeping for {delay.TotalHours:F2} hours. Next run at {nextRunTime} UTC.");

            await Task.Delay(delay, stoppingToken);
        }
    }

    private async Task GenerateGlobalLogsForTodayAsync(CancellationToken stoppingToken)
    {
        using var scope = _scopeFactory.CreateScope();
        var medicineRepo = scope.ServiceProvider.GetRequiredService<IMedicineRepository>();
        var logRepo = scope.ServiceProvider.GetRequiredService<IMedicineLogRepository>();

        var today = DateTime.UtcNow.Date;
        string currentDayNum = ((int)today.DayOfWeek).ToString();

        _logger.LogInformation($"Running Global Generation for {today:yyyy-MM-dd} (Day {currentDayNum})...");

        var allActiveMeds = await medicineRepo.GetAllActiveMedicinesAsync();
        var existingLogs = await logRepo.GetAllLogsByDateAsync(today);

        var existingMedicineIds = existingLogs.Select(l => l.MedicineId).ToHashSet();

        // 3. TARİH FİLTRESİ EKLENDİ: Gece yarısı üretimi yapılırken de ilacın tarih sınırlarına bakılıyor!
        var medsForToday = allActiveMeds.Where(m => m.DaysOfWeek.Contains(currentDayNum)
                                                && today >= m.StartDate.Date
                                                && today <= (m.EndDate?.Date ?? DateTime.MaxValue))
                                       .ToList();

        var newLogs = new List<MedicineLog>();

        foreach (var med in medsForToday)
        {
            if (!existingMedicineIds.Contains(med.Id))
            {
                newLogs.Add(new MedicineLog
                {
                    MedicineId = med.Id,
                    PatientId = med.PatientId,
                    Status = MedicineStatus.Pending,
                    ScheduledAt = today.Add(med.ScheduleTime)
                });
            }
        }

        if (newLogs.Any())
        {
            await logRepo.AddRangeAsync(newLogs);
            _logger.LogInformation($"SUCCESS: Auto-generated {newLogs.Count} missing medicine logs for today.");
        }
        else
        {
            _logger.LogInformation("No new logs needed. System is fully synced.");
        }
    }
}