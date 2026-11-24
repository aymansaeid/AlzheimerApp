using AlzheimerApp.Application.Interfaces.Services;

namespace AlzheimerApp.API.BackgroundJobs;

/// <summary>
/// Every 5 minutes: marks doses still pending <c>MissedAfter</c> (default 60 min) after their time as Missed
/// and push-notifies the care team ("Hasta ilacını almadı", FCM type MEDICATION_MISSED).
/// </summary>
public class MedicineStatusSweeperWorker : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<MedicineStatusSweeperWorker> _logger;

    public MedicineStatusSweeperWorker(IServiceScopeFactory scopeFactory, ILogger<MedicineStatusSweeperWorker> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Medicine status sweeper started.");

        using var timer = new PeriodicTimer(TimeSpan.FromMinutes(5));
        do
        {
            try
            {
                // Create a scope to resolve Scoped services like our DbContext and Application Services
                using var scope = _scopeFactory.CreateScope();
                var logService = scope.ServiceProvider.GetRequiredService<IMedicineLogService>();

                int missed = await logService.MarkOverdueLogsAsMissedAsync();
                if (missed > 0) _logger.LogInformation("Marked {Count} medicine doses as missed.", missed);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while sweeping for missed medicines.");
            }
        }
        while (await timer.WaitForNextTickAsync(stoppingToken));
    }
}