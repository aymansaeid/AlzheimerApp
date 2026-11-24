using AlzheimerApp.Application.Interfaces.Services;

namespace AlzheimerApp.API.BackgroundJobs;

/// <summary>
/// At startup and every day at 00:01 local time (Europe/Istanbul by default): creates today's Pending dose logs
/// for every active medicine, so reminders and missed-dose alerts work even if nobody opens the app.
/// </summary>
public class MedicineDailyGeneratorWorker : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly IMedicineScheduleSettings _settings;
    private readonly TimeProvider _clock;
    private readonly ILogger<MedicineDailyGeneratorWorker> _logger;

    public MedicineDailyGeneratorWorker(
        IServiceScopeFactory scopeFactory,
        IMedicineScheduleSettings settings,
        TimeProvider clock,
        ILogger<MedicineDailyGeneratorWorker> logger)
    {
        _scopeFactory = scopeFactory;
        _settings = settings;
        _clock = clock;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Medicine daily generator started (time zone: {TimeZone}).", _settings.TimeZone.Id);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var logService = scope.ServiceProvider.GetRequiredService<IMedicineLogService>();

                int created = await logService.GenerateLogsForTodayAsync();
                _logger.LogInformation("Medicine daily generator created {Count} dose logs for today.", created);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "CRITICAL ERROR: Medicine daily generator failed to generate logs.");
            }

            await Task.Delay(DelayUntilNextLocalRun(), stoppingToken);
        }
    }

    /// <summary>Time until 00:01 tomorrow in the configured time zone.</summary>
    private TimeSpan DelayUntilNextLocalRun()
    {
        var nowUtc = _clock.GetUtcNow().UtcDateTime;
        var localNow = TimeZoneInfo.ConvertTimeFromUtc(nowUtc, _settings.TimeZone);
        var nextLocalRun = DateTime.SpecifyKind(localNow.Date.AddDays(1).AddMinutes(1), DateTimeKind.Unspecified);
        var nextRunUtc = TimeZoneInfo.ConvertTimeToUtc(nextLocalRun, _settings.TimeZone);

        var delay = nextRunUtc - nowUtc;
        return delay > TimeSpan.Zero ? delay : TimeSpan.FromMinutes(1);
    }
}