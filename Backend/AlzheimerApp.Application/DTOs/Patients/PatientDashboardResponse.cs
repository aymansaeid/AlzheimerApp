using AlzheimerApp.Application.DTOs.Followers;
using AlzheimerApp.Application.DTOs.MedicineLogs;

namespace AlzheimerApp.Application.DTOs.Patients;

public class PatientDashboardResponse
{
    public string PatientName { get; set; } = string.Empty;

    public List<MedicineLogResponse> TodayMedicines { get; set; } = new();

    public List<CareTeamMemberResponse> LovedOnes { get; set; } = new();
}