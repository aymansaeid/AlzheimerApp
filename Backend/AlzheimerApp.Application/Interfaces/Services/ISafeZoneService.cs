using AlzheimerApp.Application.DTOs.SafeZones;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface ISafeZoneService
{
    /// <summary>A patient's safe zones, oldest first. Inactive (paused) zones only when <paramref name="includeInactive"/>.</summary>
    Task<List<SafeZoneResponse>> GetPatientSafeZonesAsync(Guid patientId, bool includeInactive = false);

    Task<SafeZoneResponse> CreateSafeZoneAsync(CreateSafeZoneDto dto);
    Task UpdateSafeZoneAsync(Guid id, UpdateSafeZoneRequest request);
    Task DeleteSafeZoneAsync(Guid id);
}