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
    /// The UTC instant this medicine is due on <paramref name="localDate"/>, or <c>null</c> if it is not due that day
    /// (wrong weekday, outside start/end dates, or a dose time that had already passed when the medicine was created).
    /// </summary>
    public static DateTime? DoseTimeUtc(Medicine medicine, DateOnly localDate, TimeZoneInfo timeZone)
    {
        if (!medicine.IsActive) return null;
        if (!IsScheduledOn(medicine.DaysOfWeek, localDate.DayOfWeek)) return null;

        if (localDate < LocalDate(medicine.StartDate, timeZone)) return null;
        if (medicine.EndDate.HasValue && localDate > LocalDate(medicine.EndDate.Value, timeZone)) return null;

        var dueUtc = LocalToUtc(localDate, medicine.ScheduleTime, timeZone);

        // A medicine added at 15:00 with a 09:00 dose starts tomorrow, instead of appearing as "missed" today.
        if (dueUtc < EnsureUtc(medicine.CreatedAt)) return null;

        return dueUtc;
    }

    private static DateTime EnsureUtc(DateTime value) => value.Kind switch
    {
        DateTimeKind.Utc => value,
        DateTimeKind.Local => value.ToUniversalTime(),
        _ => DateTime.SpecifyKind(value, DateTimeKind.Utc) // Npgsql returns timestamptz as UTC; unspecified = UTC here
    };
}