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

            // 👉 THE CLOCK: Calculate the exact time until the next 00:01 AM (UTC)
            var now = DateTime.UtcNow;
            var nextRunTime = now.Date.AddDays(1).AddMinutes(1); // 1 minute past midnight tomorrow
            var delay = nextRunTime - now;

            _logger.LogInformation($"Midnight Sweeper sleeping for {delay.TotalHours:F2} hours. Next run at {nextRunTime} UTC.");

            // Put the worker to sleep until tomorrow night
            await Task.Delay(delay, stoppingToken);
        }
    }

    private async Task GenerateGlobalLogsForTodayAsync(CancellationToken stoppingToken)
    {
        // 1. Open a secure dependency injection scope
        using var scope = _scopeFactory.CreateScope();
        var medicineRepo = scope.ServiceProvider.GetRequiredService<IMedicineRepository>();
        var logRepo = scope.ServiceProvider.GetRequiredService<IMedicineLogRepository>();

        var today = DateTime.UtcNow.Date;
        string currentDayNum = ((int)today.DayOfWeek).ToString();

        _logger.LogInformation($"Running Global Generation for {today:yyyy-MM-dd} (Day {currentDayNum})...");

        // 2. Fetch the entire system state
        var allActiveMeds = await medicineRepo.GetAllActiveMedicinesAsync();
        var existingLogs = await logRepo.GetAllLogsByDateAsync(today);

        // Map existing logs to a HashSet for lightning-fast O(1) lookups
        var existingMedicineIds = existingLogs.Select(l => l.MedicineId).ToHashSet();

        // 3. Filter only medicines scheduled for today's day of the week
        var medsForToday = allActiveMeds.Where(m => m.DaysOfWeek.Contains(currentDayNum)).ToList();

        var newLogs = new List<MedicineLog>();

        // 4. Generate logs ONLY if they don't already exist
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

        // 5. Bulk Save to PostgreSQL
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