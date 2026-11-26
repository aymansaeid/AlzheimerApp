using System.Collections.Concurrent;

namespace AlzheimerApp.API.BackgroundJobs;

/// <summary>
/// In-memory record of when each background worker last ran, shown by <c>GET /health</c>.
/// If <c>processStartedAt</c> keeps jumping forward, the host (e.g. Render free plan) is putting the app to sleep,
/// and reminders / missed-dose alerts are not running while it sleeps.
/// </summary>
public class WorkerHeartbeat
{
    public record WorkerStatus(DateTime? LastRunUtc, DateTime? LastSuccessUtc, string? LastError, int? LastResult);

    private readonly ConcurrentDictionary<string, WorkerStatus> _workers = new();

    public DateTime ProcessStartedAtUtc { get; } = DateTime.UtcNow;

    public void Success(string worker, int? result = null)
    {
        var now = DateTime.UtcNow;
        _workers.AddOrUpdate(worker,
            _ => new WorkerStatus(now, now, null, result),
            (_, old) => old with { LastRunUtc = now, LastSuccessUtc = now, LastResult = result });
    }

    public void Failure(string worker, Exception ex)
    {
        var now = DateTime.UtcNow;
        var error = $"{ex.GetType().Name}: {ex.Message}";
        _workers.AddOrUpdate(worker,
            _ => new WorkerStatus(now, null, error, null),
            (_, old) => old with { LastRunUtc = now, LastError = error });
    }

    public IReadOnlyDictionary<string, WorkerStatus> Snapshot() => new Dictionary<string, WorkerStatus>(_workers);
}