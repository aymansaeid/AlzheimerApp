namespace AlzheimerApp.Application.DTOs.Medicines;

/// <summary>
/// Body of <c>POST /api/Medicine</c>. One request = one medicine with all of its daily times.
/// The creator is taken from the JWT token.
/// </summary>
public class MedicineRequest
{
    public Guid PatientId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Dosage { get; set; } = string.Empty;
    public string? Instructions { get; set; }

    /// <summary>All daily times in local (Turkey) time, e.g. ["08:00:00", "20:00:00"]. At least one.</summary>
    public List<TimeSpan> ScheduleTimes { get; set; } = new();

    /// <summary>Deprecated: single time for old app versions. Used only when <see cref="ScheduleTimes"/> is empty.</summary>
    public TimeSpan? ScheduleTime { get; set; }

    /// <summary>Comma-separated weekdays: 0 = Sunday … 6 = Saturday (7 is also accepted as Sunday). e.g. "1,3,5".</summary>
    public string DaysOfWeek { get; set; } = string.Empty;

    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
}