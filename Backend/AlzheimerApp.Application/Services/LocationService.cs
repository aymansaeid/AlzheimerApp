using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Services;

public class LocationService : ILocationService
{
    private readonly ILocationLogRepository _locationRepository;
    // Later we will inject an ISafeZoneService here to calculate if the patient left the zone!

    public LocationService(ILocationLogRepository locationRepository)
    {
        _locationRepository = locationRepository;
    }

    public async Task<LocationLog> LogLocationAsync(LocationDto dto)
    {
        var locationLog = new LocationLog
        {
            PatientId = dto.PatientId,
            Latitude = dto.Latitude,
            Longitude = dto.Longitude,
            AccuracyMeters = dto.AccuracyMeters,
            RecordedAt = DateTime.UtcNow,
            IsOutsideZone = false, // We will add the geographic distance calculation logic here later!
            AlertSent = false
        };

        return await _locationRepository.AddAsync(locationLog);
    }
}