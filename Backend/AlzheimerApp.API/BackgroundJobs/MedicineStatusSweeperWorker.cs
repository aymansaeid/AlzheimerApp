using AlzheimerApp.Application.Interfaces.Services;

namespace AlzheimerApp.API.BackgroundJobs;

public class MedicineStatusSweeperWorker : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<MedicineStatusSweeperWorker> _logger;

    public MedicineStatusSweeperWorker(IServiceProvider serviceProvider, ILogger<MedicineStatusSweeperWorker> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Medicine Status Sweeper Worker started.");

        while (!stoppingToken.IsCancellationRequested)
        {
            _logger.LogInformation($"Sweeping for missed medicines at: {DateTimeOffset.Now}");

            try
            {
                // Create a scope to resolve Scoped services like our DbContext and Application Services
                using (var scope = _serviceProvider.CreateScope())
                {
                    var logService = scope.ServiceProvider.GetRequiredService<IMedicineLogService>();

                    // Trigger the sweep!
                    await logService.MarkOverdueLogsAsMissedAsync();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "An error occurred while sweeping for missed medicines.");
            }

            // Sleep for 1 Hour, then wake up and check again.
            // In a real production app, you might use a library like Hangfire or Quartz.NET, 
            // but for a graduation project MVP, this native BackgroundService is perfectly clean.
            await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
        }
    }
}