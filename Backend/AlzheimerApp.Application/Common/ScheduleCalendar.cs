using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Common;

/// <summary>
/// Converts medicine schedules between the patient's local wall-clock time and UTC.
/// </summary>
/// <remarks>
/// <c>Medicine.ScheduleTime</c> is what the caregiver picked on the phone ("09:00" = 09:00 in Turkey).
/// <c>MedicineLog.ScheduledAt</c> is always stored as a real UTC instant (09:00 TRT = 06:00Z).
/// </remarks>
public static class ScheduleCalendar
{
    /// <summary>The calendar date at <paramref name="utc"/> in the given time zone.</summary>
    public static DateOnly LocalDate(DateTime utc, TimeZoneInfo timeZone) =>
        DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(EnsureUtc(utc), timeZone));

    /// <summary>
    /// Resolves a date coming from the API or a caller:
    /// a UTC/local instant is converted to the local calendar date; an unspecified date (e.g. "2026-11-24" in a route)
    /// is already a local calendar date.
    /// </summary>
    public static DateOnly ResolveLocalDate(DateTime value, TimeZoneInfo timeZone) =>
        value.Kind == DateTimeKind.Unspecified
            ? DateOnly.FromDateTime(value)
            : LocalDate(value.ToUniversalTime(), timeZone);

    /// <summary>The UTC instant of a local date + wall-clock time.</summary>
    public static DateTime LocalToUtc(DateOnly date, TimeSpan timeOfDay, TimeZoneInfo timeZone)
    {
        var local = DateTime.SpecifyKind(date.ToDateTime(TimeOnly.MinValue).Add(timeOfDay), DateTimeKind.Unspecified);

        // A wall-clock time skipped by a DST jump does not exist; move it forward one hour (Turkey has no DST).
        if (timeZone.IsInvalidTime(local)) local = local.AddHours(1);

        return TimeZoneInfo.ConvertTimeToUtc(local, timeZone);
    }

    /// <summary>[start, end) of a local calendar day, in UTC.</summary>
    public static (DateTime FromUtc, DateTime ToUtc) LocalDayRangeUtc(DateOnly date, TimeZoneInfo timeZone) =>
        (LocalToUtc(date, TimeSpan.Zero, timeZone), LocalToUtc(date.AddDays(1), TimeSpan.Zero, timeZone));

    /// <summary>"HH:mm" of a UTC instant in the given time zone, for notification texts.</summary>
    public static string FormatLocalTime(DateTime utc, TimeZoneInfo timeZone) =>
        TimeZoneInfo.ConvertTimeFromUtc(EnsureUtc(utc), timeZone).ToString("HH:mm");

    /// <summary>
    /// True if a "1,3,5"-style list contains the day. 0 = Sunday … 6 = Saturday; 7 is also accepted as Sunday.
    /// </summary>
    public static bool IsScheduledOn(string? daysOfWeek, DayOfWeek day)
    {
        if (string.IsNullOrWhiteSpace(daysOfWeek)) return false;

        foreach (var part in daysOfWeek.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            if (int.TryParse(part, out var n) && (n % 7) == (int)day) return true;
        }
        return false;
    }

    /// <summary>
    /// Every UTC instant this medicine is due on <paramref name="localDate"/> (one per schedule time), sorted.
    /// Empty if it is not due that day (inactive, wrong weekday, outside start/end dates).
    /// With <paramref name="skipBeforeCreation"/>, dose times that had already passed when the medicine was
    /// created are left out (a medicine added at 15:00 with a 09:00 dose starts tomorrow instead of being "missed").
    /// </summary>
    public static List<DateTime> DoseTimesUtc(Medicine medicine, DateOnly localDate, TimeZoneInfo timeZone, bool skipBeforeCreation = true)
    {
        var result = new List<DateTime>();

        if (!medicine.IsActive) return result;
        if (!IsScheduledOn(medicine.DaysOfWeek, localDate.DayOfWeek)) return result;
        if (localDate < LocalDate(medicine.StartDate, timeZone)) return result;
        if (medicine.EndDate.HasValue && localDate > LocalDate(medicine.EndDate.Value, timeZone)) return result;

        var createdAt = EnsureUtc(medicine.CreatedAt);
        foreach (var time in medicine.ScheduleTimes.Distinct().OrderBy(t => t))
        {
            var dueUtc = LocalToUtc(localDate, time, timeZone);
            if (skipBeforeCreation && dueUtc < createdAt) continue;
            result.Add(dueUtc);
        }
        return result;
    }

    /// <summary>
    /// Validates and normalizes a weekday list ("1, 3,5,7" → "0,1,3,5"; 7 = Sunday = 0).
    /// </summary>
    /// <exception cref="ArgumentException">Empty, or contains something other than 0–7.</exception>
    public static string NormalizeDaysOfWeek(string? daysOfWeek)
    {
        var days = new SortedSet<int>();
        foreach (var part in (daysOfWeek ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            if (!int.TryParse(part, out var n) || n < 0 || n > 7)
                throw new ArgumentException("daysOfWeek must be a comma-separated list of 0–6 (0 = Sunday; 7 is also accepted as Sunday).");
            days.Add(n % 7);
        }

        if (days.Count == 0) throw new ArgumentException("Select at least one day (daysOfWeek).");
        return string.Join(",", days);
    }

    /// <summary>
    /// Validates and normalizes schedule times: at least one, at most 12, each within a day, duplicates removed, sorted.
    /// </summary>
    /// <exception cref="ArgumentException">Invalid list.</exception>
    public static List<TimeSpan> NormalizeScheduleTimes(IEnumerable<TimeSpan>? times)
    {
        var list = (times ?? Enumerable.Empty<TimeSpan>())
            .Select(t => TimeSpan.FromMinutes(Math.Floor(t.TotalMinutes))) // drop seconds
            .ToList();

        if (list.Count == 0) throw new ArgumentException("Add at least one time (scheduleTimes).");
        if (list.Any(t => t < TimeSpan.Zero || t >= TimeSpan.FromDays(1)))
            throw new ArgumentException("Each schedule time must be between 00:00 and 23:59.");

        var normalized = list.Distinct().OrderBy(t => t).ToList();
        if (normalized.Count > 12) throw new ArgumentException("A medicine can have at most 12 times per day.");
        return normalized;
    }
    private static DateTime EnsureUtc(DateTime value) => value.Kind switch
    {
        DateTimeKind.Utc => value,
        DateTimeKind.Local => value.ToUniversalTime(),
        _ => DateTime.SpecifyKind(value, DateTimeKind.Utc) // Npgsql returns timestamptz as UTC; unspecified = UTC here
    };
}