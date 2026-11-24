using AlzheimerApp.Application.DTOs.Locations;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface ILocationLogRepository
{
    Task<LocationLog> AddAsync(LocationLog locationLog);
    Task<List<LocationLog>> GetPatientLocationsAsync(Guid patientId, DateTime since);
    Task<LocationLog?> GetLatestLocationAsync(Guid patientId);
    Task<LocationLog?> GetLastLocationByPatientIdAsync(Guid patientId);
    Task<List<LocationLog>> GetLocationHistoryAsync(Guid patientId, DateTime startTime, DateTime endTime);

    /// <summary>
    /// Single-query projection: patients (all of them when <paramref name="followerId"/> is null,
    /// otherwise only those linked to that follower) with their most recent location, or null if none.
    /// </summary>
    Task<List<PatientLatestLocationResponse>> GetLatestLocationsForPatientsAsync(Guid? followerId, CancellationToken cancellationToken = default);
}