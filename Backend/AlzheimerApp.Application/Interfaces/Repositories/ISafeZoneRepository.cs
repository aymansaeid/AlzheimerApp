using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface ISafeZoneRepository
{
    Task<SafeZone?> GetByIdAsync(Guid id);
    Task<List<SafeZone>> GetActiveSafeZonesByPatientIdAsync(Guid patientId);
    Task<SafeZone> AddAsync(SafeZone safeZone);
    Task UpdateAsync(SafeZone safeZone);
    Task DeleteAsync(SafeZone safeZone);
}