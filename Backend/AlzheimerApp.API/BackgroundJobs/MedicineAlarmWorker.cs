using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;
using AlzheimerApp.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AlzheimerApp.API.BackgroundJobs;

public class MedicineAlarmWorker : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<MedicineAlarmWorker> _logger;

    public MedicineAlarmWorker(IServiceScopeFactory scopeFactory, ILogger<MedicineAlarmWorker> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Medicine Alarm Engine is online...");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await TriggerDueAlarmsAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process medicine alarms.");
            }

            // 👉 THE CLOCK: Wait exactly 1 minute, then check again
            await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
        }
    }

    private async Task TriggerDueAlarmsAsync()
    {
        using var scope = _scopeFactory.CreateScope();

        // Resolve our required services from the scope
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();
        var followerRepo = scope.ServiceProvider.GetRequiredService<IPatientFollowerRepository>();

        var now = DateTime.UtcNow;

        // 1. Find EXACT logs that are due right now and haven't triggered their specific alarm yet
        var dueLogs = await context.MedicineLogs
            .Include(ml => ml.Medicine)
            .Include(ml => ml.Patient)
            .Where(ml => ml.Status == MedicineStatus.Pending
                      && ml.ScheduledAt <= now
                      && !ml.IsAlarmSent) // 🛡️ The ultimate anti-spam flag
            .ToListAsync();

        if (!dueLogs.Any()) return;

        foreach (var log in dueLogs)
        {
            string medicineName = log.Medicine?.Name ?? "Medication";
            string patientName = log.Patient?.FullName ?? "The patient";

            // 2. Get tokens for the Care Team to send the Firebase Alert
            var followers = await followerRepo.GetFollowersByPatientIdAsync(log.PatientId);
            var tokens = followers
                .Where(f => f.Follower != null && !string.IsNullOrEmpty(f.Follower.FcmToken))
                .Select(f => f.Follower!.FcmToken!)
                .ToList();

            if (tokens.Any())
            {
                await notificationService.SendMulticastAlertAsync(
                    tokens,
                    "Time for Medication! 💊",
                    $"It's time for {patientName} to take {medicineName}.",
                    "MedicineReminder"
                );
            }

            // 3. Mark THIS SPECIFIC PILL as alerted so it never fires again
            log.IsAlarmSent = true;

            // 4. Create the Audit Trail for the frontend Notification Center UI
            var newAlert = new AlertHistory
            {
                PatientId = log.PatientId,
                AlertType = AlertType.MedicineReminder,
                Message = $"Reminder: {medicineName} is due for {patientName}.",
                IsRead = false,
                SentAt = DateTime.UtcNow
            };

            context.AlertHistories.Add(newAlert);
        }

        // 5. Save the updated flags and the new history records to PostgreSQL in one transaction
        await context.SaveChangesAsync();
        _logger.LogInformation($"Successfully fired {dueLogs.Count} medicine alarms.");
    }
}