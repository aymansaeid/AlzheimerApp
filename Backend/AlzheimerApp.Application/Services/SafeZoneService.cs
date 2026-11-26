using AlzheimerApp.Application.DTOs.SafeZones;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Services;

public class SafeZoneService : ISafeZoneService
{
    private readonly ISafeZoneRepository _safeZoneRepository;

    public SafeZoneService(ISafeZoneRepository safeZoneRepository)
    {
        _safeZoneRepository = safeZoneRepository;
    }

    public async Task<List<SafeZoneResponse>> GetPatientSafeZonesAsync(Guid patientId, bool includeInactive = false)
    {
        var zones = await _safeZoneRepository.GetByPatientIdAsync(patientId, includeInactive);
        return zones.Select(SafeZoneResponse.FromEntity).ToList();
    }

    public async Task<SafeZoneResponse> CreateSafeZoneAsync(CreateSafeZoneDto dto)
    {
        var safeZone = new SafeZone
        {
            PatientId = dto.PatientId,
            Name = dto.Name,
            CenterLat = dto.CenterLat,
            CenterLng = dto.CenterLng,
            RadiusMeters = dto.RadiusMeters,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        // Save it to the database
        var savedEntity = await _safeZoneRepository.AddAsync(safeZone);

        return SafeZoneResponse.FromEntity(savedEntity);
    }

    public async Task UpdateSafeZoneAsync(Guid id, UpdateSafeZoneRequest request)
    {
        var safeZone = await _safeZoneRepository.GetByIdAsync(id);
        if (safeZone == null) throw new Exception("Safe Zone not found.");

        safeZone.Name = request.Name;
        safeZone.CenterLat = request.CenterLat;
        safeZone.CenterLng = request.CenterLng;
        safeZone.RadiusMeters = request.RadiusMeters;
        safeZone.IsActive = request.IsActive;

        await _safeZoneRepository.UpdateAsync(safeZone);
    }

    public async Task DeleteSafeZoneAsync(Guid id)
    {
        var safeZone = await _safeZoneRepository.GetByIdAsync(id);
        if (safeZone == null) throw new Exception("Safe Zone not found.");

        await _safeZoneRepository.DeleteAsync(safeZone);
    }
}