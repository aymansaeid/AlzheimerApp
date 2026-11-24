namespace AlzheimerApp.Application.DTOs.Medicines;

/// <summary>
/// Body of <c>PUT /api/Medicine/{id}</c>: the full new state of the medicine (send every field).
/// </summary>
public class UpdateMedicineRequest
{
    public string Name { get; set; } = string.Empty;
    public string Dosage { get; set; } = string.Empty;
    public string? Instructions { get; set; }

    /// <summary>All daily times in local (Turkey) time, e.g. ["08:00:00", "14:00:00", "20:00:00"]. At least one.</summary>
    public List<TimeSpan> ScheduleTimes { get; set; } = new();

    /// <summary>Deprecated: single time for old app versions. Used only when <see cref="ScheduleTimes"/> is empty.</summary>
    public TimeSpan? ScheduleTime { get; set; }

    public string DaysOfWeek { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public bool IsActive { get; set; } = true;
}