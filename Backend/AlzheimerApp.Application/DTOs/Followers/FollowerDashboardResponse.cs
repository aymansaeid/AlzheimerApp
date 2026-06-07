using AlzheimerApp.Application.DTOs.Alerts;
using AlzheimerApp.Application.DTOs.MedicineLogs;

namespace AlzheimerApp.Application.DTOs.Followers;

public class FollowerDashboardResponse
{
    // Patient Identity
    public Guid PatientId { get; set; }
    public string PatientName { get; set; } = string.Empty;

    // Real-time Status
    public double? LastLatitude { get; set; }
    public double? LastLongitude { get; set; }
    public bool IsCurrentlyOutside { get; set; }
    public DateTime? LastSeenAt { get; set; }

    // Alert Summary
    public int UnreadAlertCount { get; set; }
    public AlertResponse? LatestAlert { get; set; }

    // Medicine Summary for Today
    public int MedsTakenToday { get; set; }
    public int TotalMedsToday { get; set; }
    public List<MedicineLogResponse> UpcomingMeds { get; set; } = new();
    public bool CurrentUserIsAdmin { get; set; }
}