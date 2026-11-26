using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface ISafeZoneRepository
{
    Task<SafeZone?> GetByIdAsync(Guid id);
    Task<List<SafeZone>> GetActiveSafeZonesByPatientIdAsync(Guid patientId);

    /// <summary>All safe zones of one patient (inactive ones only when <paramref name="includeInactive"/>), oldest first. Read-only.</summary>
    Task<List<SafeZone>> GetByPatientIdAsync(Guid patientId, bool includeInactive);

    /// <summary>Active safe zones of many patients in ONE query (for the overview map). Read-only.</summary>
    Task<List<SafeZone>> GetActiveByPatientIdsAsync(IReadOnlyCollection<Guid> patientIds, CancellationToken cancellationToken = default);

    Task<SafeZone> AddAsync(SafeZone safeZone);
    Task UpdateAsync(SafeZone safeZone);
    Task DeleteAsync(SafeZone safeZone);
}