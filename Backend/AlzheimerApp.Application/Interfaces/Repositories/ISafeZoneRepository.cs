using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface ISafeZoneRepository
{
    Task<List<SafeZone>> GetActiveSafeZonesByPatientIdAsync(Guid patientId);
    Task<SafeZone> AddAsync(SafeZone safeZone); 
}