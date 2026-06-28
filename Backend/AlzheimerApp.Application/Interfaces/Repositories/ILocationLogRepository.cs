using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface ILocationLogRepository
{
    Task<LocationLog> AddAsync(LocationLog locationLog);
    Task<List<LocationLog>> GetPatientLocationsAsync(Guid patientId, DateTime since);
    Task<LocationLog?> GetLatestLocationAsync(Guid patientId);
    Task<LocationLog?> GetLastLocationByPatientIdAsync(Guid patientId);
    Task<List<LocationLog>> GetLocationHistoryAsync(Guid patientId, DateTime startTime, DateTime endTime);
}