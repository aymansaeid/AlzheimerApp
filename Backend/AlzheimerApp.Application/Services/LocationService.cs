using AlzheimerApp.Application.DTOs.Locations;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;
using AlzheimerApp.Application.DTOs.SafeZones;
namespace AlzheimerApp.Application.Services;

public class LocationService : ILocationService
{
    private readonly ILocationLogRepository _locationRepository;
    private readonly ISafeZoneRepository _safeZoneRepository;
    private readonly IPatientFollowerRepository _followerRepository;
    private readonly INotificationService _notificationService;
    private readonly IAlertHistoryRepository _alertRepository;
    private readonly IUserRepository _userRepository;

    public LocationService(
        ILocationLogRepository locationRepository,
        ISafeZoneRepository safeZoneRepository,
        IPatientFollowerRepository followerRepository,
        INotificationService notificationService,
        IAlertHistoryRepository alertRepository,
        IUserRepository userRepository)
    {
        _locationRepository = locationRepository;
        _safeZoneRepository = safeZoneRepository;
        _followerRepository = followerRepository;
        _notificationService = notificationService;
        _alertRepository = alertRepository;
        _userRepository = userRepository;
    }

    public async Task<LocationLogResponse> LogLocationAsync(Guid patientId, LocationRequest request)
    {
        // 0. Girdi doğrulama (hatalı GPS/pil verisi güvenli bölge hesabını bozmasın)
        if (request.Latitude is < -90 or > 90 || request.Longitude is < -180 or > 180)
            throw new ArgumentException("Latitude must be between -90 and 90, longitude between -180 and 180.");

        if (request.BatteryLevel is < 0 or > 100)
            throw new ArgumentException("Battery level must be between 0 and 100.");

        var activeSafeZones = await _safeZoneRepository.GetActiveSafeZonesByPatientIdAsync(patientId);
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

        // 2. SPAM ENGELLEYİCİ MANTIK
        // Hastanın veritabanındaki en son kaydedilen konumunu getir
        var lastLocation = await _locationRepository.GetLastLocationByPatientIdAsync(patientId);

        // Eğer hastanın önceki konumu zaten "Dışarıda" ise, tekrar bildirim atmamıza gerek yok (wasOutside = true)
        bool wasAlreadyOutside = lastLocation != null && lastLocation.IsOutsideZone;

        // THE ALARM TRIGGER LOGIC
        // SADECE VE SADECE şu an dışarıdaysa VE daha önce içerideyken YENİ dışarı çıkmışsa alarm ver!
        if (isCurrentlyOutside && !wasAlreadyOutside)
        {
            var patient = await _userRepository.GetByIdAsync(patientId);
            string patientName = patient?.FullName ?? "Hasta";
            string zoneName = activeSafeZones.Count == 1 ? activeSafeZones[0].Name : "Güvenli Alan";
            string alertMessage = $"{patientName} güvenli bölgenin ({zoneName}) dışına çıktı!";

            var alertHistory = new AlertHistory
            {
                PatientId = patientId,
                AlertType = AlertType.SafeZoneBreach,
                Message = alertMessage,
                IsRead = false,
                SentAt = DateTime.UtcNow
            };
            await _alertRepository.AddAsync(alertHistory);

            var followers = await _followerRepository.GetFollowersByPatientIdAsync(patientId);
            var tokens = followers
                .Where(f => f.Follower != null && !string.IsNullOrEmpty(f.Follower.FcmToken))
                .Select(f => f.Follower!.FcmToken!)
                .ToList();

            if (tokens.Any())
            {
                alertSent = await _notificationService.SendMulticastAsync(
                    tokens,
                    "⚠️ Güvenli bölge ihlali!",
                    alertMessage,
                    new Dictionary<string, string>
                    {
                        // notification_service.dart switches on "type"
                        ["type"] = "SAFEZONE_EXIT",
                        ["alertType"] = AlertType.SafeZoneBreach.ToString(),
                        ["patientId"] = patientId.ToString(),
                        ["patientName"] = patientName,
                        ["zoneName"] = zoneName,
                        ["latitude"] = request.Latitude.ToString(System.Globalization.CultureInfo.InvariantCulture),
                        ["longitude"] = request.Longitude.ToString(System.Globalization.CultureInfo.InvariantCulture)
                    });
            }
        }

        // 3. Konumu her halükarda logla (Harita çizimi için bu şart)
        var locationLog = new LocationLog
        {
            PatientId = patientId,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            AccuracyMeters = request.AccuracyMeters,
            RecordedAt = DateTime.UtcNow,
            IsOutsideZone = isCurrentlyOutside, // Güncel durumu kaydet
            AlertSent = alertSent,
            BatteryLevel = request.BatteryLevel,
            IsCharging = request.IsCharging
        };

        var saved = await _locationRepository.AddAsync(locationLog);
        return MapToResponse(saved, profilePhotoUrl: null);
    }

    public async Task<bool> CanTrackPatientAsync(Guid userId, bool isSystemAdmin, Guid patientId)
    {
        if (isSystemAdmin || userId == patientId) return true;
        return await _followerRepository.RelationshipExistsAsync(patientId, userId);
    }

    public async Task<LocationLogResponse?> GetLatestLocationAsync(Guid patientId)
    {
        var lastLocation = await _locationRepository.GetLastLocationByPatientIdAsync(patientId);

        if (lastLocation == null) return null;

        var profilePhotoUrl = await _userRepository.GetProfilePhotoUrlAsync(patientId);
        return MapToResponse(lastLocation, profilePhotoUrl);
    }

    public async Task<List<LocationLogResponse>> GetLocationHistoryAsync(Guid patientId, DateTime startTime, DateTime endTime)
    {
        var history = await _locationRepository.GetLocationHistoryAsync(patientId, startTime, endTime);
        if (history.Count == 0) return new List<LocationLogResponse>();

        // One lookup for the whole history instead of one per point.
        var profilePhotoUrl = await _userRepository.GetProfilePhotoUrlAsync(patientId);

        return history.Select(l => MapToResponse(l, profilePhotoUrl)).ToList();
    }

    public async Task<List<PatientLatestLocationResponse>> GetLatestLocationsForCareTeamAsync(Guid requesterId, bool isSystemAdmin, CancellationToken cancellationToken = default)
    {
        // System admins see every patient; caregivers only see patients they are linked to.
        Guid? followerFilter = isSystemAdmin ? null : requesterId;
        var patients = await _locationRepository.GetLatestLocationsForPatientsAsync(followerFilter, cancellationToken);

        // Attach every patient's active safe zones with ONE extra query, so the map needs no request per patient.
        var zones = await _safeZoneRepository.GetActiveByPatientIdsAsync(
            patients.Select(p => p.PatientId).ToList(), cancellationToken);
        var zonesByPatient = zones.ToLookup(z => z.PatientId);

        foreach (var patient in patients)
        {
            patient.SafeZones = zonesByPatient[patient.PatientId].Select(SafeZoneResponse.FromEntity).ToList();
        }

        return patients;
    }
    private static LocationLogResponse MapToResponse(LocationLog log, string? profilePhotoUrl) => new()
    {
        PatientId = log.PatientId,
        ProfilePhotoUrl = profilePhotoUrl,
        Latitude = log.Latitude,
        Longitude = log.Longitude,
        AccuracyMeters = log.AccuracyMeters,
        RecordedAt = log.RecordedAt,
        IsOutsideZone = log.IsOutsideZone,
        BatteryLevel = log.BatteryLevel,
        IsCharging = log.IsCharging
    };

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