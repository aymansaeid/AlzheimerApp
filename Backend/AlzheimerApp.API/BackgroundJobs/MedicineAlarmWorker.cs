using AlzheimerApp.Application.Interfaces.Services;

namespace AlzheimerApp.API.BackgroundJobs;

/// <summary>
/// Every minute: sends the patient a "did you take your medicine?" push for doses still pending
/// <c>ReminderDelay</c> (default 15 min) after their time. The exact-time alarm is a local notification
/// scheduled by the app itself, so it also works offline.
/// </summary>
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
        _logger.LogInformation("Medicine reminder worker started.");

        using var timer = new PeriodicTimer(TimeSpan.FromMinutes(1));
        do
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var logService = scope.ServiceProvider.GetRequiredService<IMedicineLogService>();

                int sent = await logService.SendDueRemindersAsync();
                if (sent > 0) _logger.LogInformation("Sent {Count} medicine reminders.", sent);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to process medicine reminders.");
            }
        }
        while (await timer.WaitForNextTickAsync(stoppingToken));
    }
}