using AlzheimerApp.Application.DTOs.Locations;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface ILocationService
{
    /// <summary>
    /// Saves a GPS sample for <paramref name="patientId"/> (taken from the caller's JWT), runs the safe-zone
    /// check and returns the saved record.
    /// </summary>
    /// <exception cref="ArgumentException">Coordinates or battery level are out of range.</exception>
    Task<LocationLogResponse> LogLocationAsync(Guid patientId, LocationRequest request);

    /// <summary>
    /// True if <paramref name="userId"/> may see <paramref name="patientId"/>'s location:
    /// the patient themself, a linked care team member, or a system admin.
    /// </summary>
    Task<bool> CanTrackPatientAsync(Guid userId, bool isSystemAdmin, Guid patientId);

    Task<LocationLogResponse?> GetLatestLocationAsync(Guid patientId);
    Task<List<LocationLogResponse>> GetLocationHistoryAsync(Guid patientId, DateTime startTime, DateTime endTime);

    /// <summary>
    /// Returns every patient visible to the requester together with their single most recent location.
    /// Patients without any location are included with <c>LatestLocation = null</c>.
    /// </summary>
    /// <param name="requesterId">The caregiver's user ID (from the JWT).</param>
    /// <param name="isSystemAdmin">True for <c>UserRole.Admin</c>: returns all patients in the system.</param>
    Task<List<PatientLatestLocationResponse>> GetLatestLocationsForCareTeamAsync(Guid requesterId, bool isSystemAdmin, CancellationToken cancellationToken = default);
}