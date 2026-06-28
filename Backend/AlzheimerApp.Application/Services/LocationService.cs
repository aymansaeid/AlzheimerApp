using AlzheimerApp.Application.DTOs.Locations;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.Services;

public class LocationService : ILocationService
{
    private readonly ILocationLogRepository _locationRepository;
    private readonly ISafeZoneRepository _safeZoneRepository;
    private readonly IPatientFollowerRepository _followerRepository;
    private readonly INotificationService _notificationService;
    private readonly IAlertHistoryRepository _alertRepository;

    public LocationService(
        ILocationLogRepository locationRepository,
        ISafeZoneRepository safeZoneRepository,
        IPatientFollowerRepository followerRepository,
        INotificationService notificationService,
        IAlertHistoryRepository alertRepository)
    {
        _locationRepository = locationRepository;
        _safeZoneRepository = safeZoneRepository;
        _followerRepository = followerRepository;
        _notificationService = notificationService;
        _alertRepository = alertRepository;
    }

    public async Task<LocationLog> LogLocationAsync(LocationRequest request)
    {
        var activeSafeZones = await _safeZoneRepository.GetActiveSafeZonesByPatientIdAsync(request.PatientId);
        bool isCurrentlyOutside = false;
        bool alertSent = false;

        // 1. Yeni konum güvenli bölgelerin içinde mi kontrol et
        if (activeSafeZones.Any())
        {
            isCurrentlyOutside = true; // Başlangıçta dışarıda varsayalım
            foreach (var zone in activeSafeZones)
            {
                double distanceToCenter = CalculateDistanceMeters(request.Latitude, request.Longitude, zone.CenterLat, zone.CenterLng);
                if (distanceToCenter <= zone.RadiusMeters)
                {
                    isCurrentlyOutside = false; // Bir tane bile güvenli bölgedeyse güvendedir!
                    break;
                }
            }
        }

        // 2. SPAM ENGELLEYİCİ MANTIK (YENİ EKLENEN KISIM)
        // Hastanın veritabanındaki en son kaydedilen konumunu getir
        var lastLocation = await _locationRepository.GetLastLocationByPatientIdAsync(request.PatientId);

        // Eğer hastanın önceki konumu zaten "Dışarıda" ise, tekrar bildirim atmamıza gerek yok (wasOutside = true)
        bool wasAlreadyOutside = lastLocation != null && lastLocation.IsOutsideZone;

        // THE ALARM TRIGGER LOGIC
        // SADECE VE SADECE şu an dışarıdaysa VE daha önce içerideyken YENİ dışarı çıkmışsa alarm ver!
        if (isCurrentlyOutside && !wasAlreadyOutside)
        {
            string alertMessage = "EMERGENCY: The patient has left the designated Safe Zone!";

            var alertHistory = new AlertHistory
            {
                PatientId = request.PatientId,
                AlertType = AlertType.SafeZoneBreach,
                Message = alertMessage,
                IsRead = false,
                SentAt = DateTime.UtcNow
            };
            await _alertRepository.AddAsync(alertHistory);

            var followers = await _followerRepository.GetFollowersByPatientIdAsync(request.PatientId);
            var tokens = followers
                .Where(f => f.Follower != null && !string.IsNullOrEmpty(f.Follower.FcmToken))
                .Select(f => f.Follower!.FcmToken!)
                .ToList();

            if (tokens.Any())
            {
                alertSent = await _notificationService.SendMulticastAlertAsync(
                    tokens,
                    "Safe Zone Breach!",
                    alertMessage,
                    AlertType.SafeZoneBreach.ToString());
            }
        }

        // 3. Konumu her halükarda logla (Harita çizimi için bu şart)
        var locationLog = new LocationLog
        {
            PatientId = request.PatientId,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            AccuracyMeters = request.AccuracyMeters,
            RecordedAt = DateTime.UtcNow,
            IsOutsideZone = isCurrentlyOutside, // Güncel durumu kaydet
            AlertSent = alertSent
        };

        return await _locationRepository.AddAsync(locationLog);
    }

    private double CalculateDistanceMeters(double lat1, double lon1, double lat2, double lon2)
    {
        var R = 6371e3;
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