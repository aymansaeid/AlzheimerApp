using AlzheimerApp.Application.DTOs.Followers;

namespace AlzheimerApp.Application.Interfaces.Services;

/// <summary>
/// Answers "what may this user do for this patient?" and "which patient does this record belong to?".
/// Used by controllers before calling the business services.
/// </summary>
public interface ICareTeamAccessService
{
    Task<PatientPermissions> GetPermissionsAsync(Guid userId, bool isSystemAdmin, Guid patientId);

    Task<Guid?> GetMedicinePatientIdAsync(Guid medicineId);
    Task<Guid?> GetMedicineLogPatientIdAsync(Guid medicineLogId);
    Task<Guid?> GetSafeZonePatientIdAsync(Guid safeZoneId);
    Task<Guid?> GetAlertPatientIdAsync(Guid alertId);

    /// <summary>Patient and uploader of a memory, or null if it does not exist.</summary>
    Task<(Guid PatientId, Guid UploaderId)?> GetMemoryOwnerAsync(Guid memoryId);
}