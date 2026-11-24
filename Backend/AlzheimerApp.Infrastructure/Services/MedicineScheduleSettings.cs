using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.Extensions.Configuration;

namespace AlzheimerApp.Infrastructure.Services;

/// <summary>
/// Reads the optional <c>MedicineSettings</c> section; every value has a safe default, so nothing has to be set on Render.
/// </summary>
public class MedicineScheduleSettings : IMedicineScheduleSettings
{
    private const string DefaultTimeZoneId = "Europe/Istanbul";

    public TimeZoneInfo TimeZone { get; }
    public TimeSpan ReminderDelay { get; }
    public TimeSpan MissedAfter { get; }
    public TimeSpan NotificationWindow { get; }

    public MedicineScheduleSettings(IConfiguration configuration)
    {
        var section = configuration.GetSection("MedicineSettings");

        TimeZone = ResolveTimeZone(section["TimeZone"] ?? DefaultTimeZoneId);
        ReminderDelay = TimeSpan.FromMinutes(ReadMinutes(section["ReminderDelayMinutes"], 15));
        MissedAfter = TimeSpan.FromMinutes(ReadMinutes(section["MissedAfterMinutes"], 60));
        NotificationWindow = TimeSpan.FromMinutes(ReadMinutes(section["NotificationWindowMinutes"], 30));

        // A dose must never become "missed" before the patient's reminder is due.
        if (MissedAfter <= ReminderDelay) MissedAfter = ReminderDelay + TimeSpan.FromMinutes(15);
    }

    private static int ReadMinutes(string? value, int fallback) =>
        int.TryParse(value, out var minutes) && minutes > 0 ? minutes : fallback;

    private static TimeZoneInfo ResolveTimeZone(string id)
    {
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById(id);
        }
        catch (Exception) when (id == DefaultTimeZoneId)
        {
            // Slim Linux images may ship without tzdata. Turkey has been fixed at UTC+3 (no DST) since 2016.
            return TimeZoneInfo.CreateCustomTimeZone(DefaultTimeZoneId, TimeSpan.FromHours(3), "Türkiye", "Türkiye");
        }
    }
}