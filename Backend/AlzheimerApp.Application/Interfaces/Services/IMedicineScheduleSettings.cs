namespace AlzheimerApp.Application.Interfaces.Services;

/// <summary>
/// Medicine scheduling settings (Render env: <c>MedicineSettings__TimeZone</c>, <c>MedicineSettings__ReminderDelayMinutes</c>, ...).
/// </summary>
public interface IMedicineScheduleSettings
{
    /// <summary>Time zone in which caregivers enter dose times. Default: Europe/Istanbul.</summary>
    TimeZoneInfo TimeZone { get; }

    /// <summary>How long after the dose time the patient gets a "did you take it?" push if still pending. Default: 15 min.</summary>
    TimeSpan ReminderDelay { get; }

    /// <summary>How long after the dose time a pending dose becomes Missed and the care team is alerted. Default: 60 min.</summary>
    TimeSpan MissedAfter { get; }

    /// <summary>
    /// Notifications are only sent if processed within this window of their due moment. Older items
    /// (after downtime, or created late) are updated silently instead of flooding phones. Default: 30 min.
    /// </summary>
    TimeSpan NotificationWindow { get; }
}