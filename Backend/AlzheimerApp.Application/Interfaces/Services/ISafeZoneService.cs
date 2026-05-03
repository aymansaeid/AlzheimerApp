using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface ISafeZoneService
{
    Task<SafeZone> CreateSafeZoneAsync(CreateSafeZoneDto dto);
}