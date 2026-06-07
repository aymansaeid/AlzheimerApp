using AlzheimerApp.Application.DTOs.Patients;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;

namespace AlzheimerApp.Application.Services;

public class PatientService : IPatientService
{
    private readonly IUserRepository _userRepository;
    private readonly IMedicineLogService _medicineLogService;
    private readonly IPatientFollowerService _followerService;

    public PatientService(
        IUserRepository userRepository,
        IMedicineLogService medicineLogService,
        IPatientFollowerService followerService)
    {
        _userRepository = userRepository;
        _medicineLogService = medicineLogService;
        _followerService = followerService;
    }

    public async Task<PatientDashboardResponse> GetDashboardAsync(Guid patientId)
    {
        var patient = await _userRepository.GetByIdAsync(patientId);
        if (patient == null) throw new Exception("Hasta bulunamadı.");

        var todayLogs = await _medicineLogService.GetDailyLogsAsync(patientId, DateTime.UtcNow);
        var careTeam = await _followerService.GetCareTeamAsync(patientId);

        return new PatientDashboardResponse
        {
            PatientName = patient.FullName,
            TodayMedicines = todayLogs,
            LovedOnes = careTeam
        };
    }
}