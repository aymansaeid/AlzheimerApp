using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Services;

public class LocationService : ILocationService
{
    private readonly ILocationLogRepository _locationRepository;
    private readonly ISafeZoneRepository _safeZoneRepository;

    public LocationService(ILocationLogRepository locationRepository, ISafeZoneRepository safeZoneRepository)
    {
        _locationRepository = locationRepository;
        _safeZoneRepository = safeZoneRepository;
    }

    public async Task<LocationLog> LogLocationAsync(LocationDto dto)
    {
        // 1. Fetch active safe zones for this patient
        var activeSafeZones = await _safeZoneRepository.GetActiveSafeZonesByPatientIdAsync(dto.PatientId);

        bool isOutside = false;

        // 2. Geofencing Logic: If they have safe zones, check if they are outside ALL of them
        if (activeSafeZones.Any())
        {
            isOutside = true; // Assume outside until proven inside

            foreach (var zone in activeSafeZones)
            {
                double distanceToCenter = CalculateDistanceMeters(
                    dto.Latitude, dto.Longitude,
                    zone.CenterLat, zone.CenterLng);

                // If they are within the radius of AT LEAST ONE safe zone, they are safe.
                if (distanceToCenter <= zone.RadiusMeters)
                {
                    isOutside = false;
                    break;
                }
            }
        }

        // 3. Create the log
        var locationLog = new LocationLog
        {
            PatientId = dto.PatientId,
            Latitude = dto.Latitude,
            Longitude = dto.Longitude,
            AccuracyMeters = dto.AccuracyMeters,
            RecordedAt = DateTime.UtcNow,
            IsOutsideZone = isOutside,
            AlertSent = false // We will trigger Firebase FCM alerts in the next step!
        };

        return await _locationRepository.AddAsync(locationLog);
    }

    // Standard Haversine formula to calculate distance between two GPS coordinates in meters
    private double CalculateDistanceMeters(double lat1, double lon1, double lat2, double lon2)
    {
        var R = 6371e3; // Earth radius in meters
        var phi1 = lat1 * Math.PI / 180;
        var phi2 = lat2 * Math.PI / 180;
        var deltaPhi = (lat2 - lat1) * Math.PI / 180;
        var deltaLambda = (lon2 - lon1) * Math.PI / 180;

        var a = Math.Sin(deltaPhi / 2) * Math.Sin(deltaPhi / 2) +
                Math.Cos(phi1) * Math.Cos(phi2) *
                Math.Sin(deltaLambda / 2) * Math.Sin(deltaLambda / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

        return R * c;
    }
}