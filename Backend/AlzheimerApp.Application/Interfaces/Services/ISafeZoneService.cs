using AlzheimerApp.Application.DTOs.SafeZones;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface ISafeZoneService
{
    Task<SafeZoneResponse> CreateSafeZoneAsync(CreateSafeZoneDto dto);
    Task UpdateSafeZoneAsync(Guid id, UpdateSafeZoneRequest request);
    Task DeleteSafeZoneAsync(Guid id);
}