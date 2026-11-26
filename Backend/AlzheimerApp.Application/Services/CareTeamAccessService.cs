using AlzheimerApp.Application.DTOs.Followers;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;

namespace AlzheimerApp.Application.Services;

public class CareTeamAccessService : ICareTeamAccessService
{
    private readonly IPatientFollowerRepository _followerRepository;
    private readonly IMedicineRepository _medicineRepository;
    private readonly IMedicineLogRepository _medicineLogRepository;
    private readonly ISafeZoneRepository _safeZoneRepository;
    private readonly IAlertHistoryRepository _alertRepository;
    private readonly IMemoryContentRepository _memoryRepository;

    public CareTeamAccessService(
        IPatientFollowerRepository followerRepository,
        IMedicineRepository medicineRepository,
        IMedicineLogRepository medicineLogRepository,
        ISafeZoneRepository safeZoneRepository,
        IAlertHistoryRepository alertRepository,
        IMemoryContentRepository memoryRepository)
    {
        _followerRepository = followerRepository;
        _medicineRepository = medicineRepository;
        _medicineLogRepository = medicineLogRepository;
        _safeZoneRepository = safeZoneRepository;
        _alertRepository = alertRepository;
        _memoryRepository = memoryRepository;
    }

    public async Task<PatientPermissions> GetPermissionsAsync(Guid userId, bool isSystemAdmin, Guid patientId)
    {
        if (isSystemAdmin) return PatientPermissions.ForSystemAdmin();
        if (userId == patientId) return PatientPermissions.ForPatientSelf();

        var relationship = await _followerRepository.GetRelationshipAsync(patientId, userId);
        return relationship == null
            ? PatientPermissions.None
            : PatientPermissions.ForFollower(relationship.IsPrimary);
    }

    public async Task<Guid?> GetMedicinePatientIdAsync(Guid medicineId) =>
        (await _medicineRepository.GetByIdAsync(medicineId))?.PatientId;

    public async Task<Guid?> GetMedicineLogPatientIdAsync(Guid medicineLogId) =>
        (await _medicineLogRepository.GetByIdAsync(medicineLogId))?.PatientId;

    public async Task<Guid?> GetSafeZonePatientIdAsync(Guid safeZoneId) =>
        (await _safeZoneRepository.GetByIdAsync(safeZoneId))?.PatientId;

    public async Task<Guid?> GetAlertPatientIdAsync(Guid alertId) =>
        (await _alertRepository.GetByIdAsync(alertId))?.PatientId;

    public async Task<(Guid PatientId, Guid UploaderId)?> GetMemoryOwnerAsync(Guid memoryId)
    {
        var memory = await _memoryRepository.GetByIdAsync(memoryId);
        return memory == null ? null : (memory.PatientId, memory.UploadedBy);
    }
}