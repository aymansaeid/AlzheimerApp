import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

enum LocationAccessStatus {
  granted, // İzin verildi, kullanılabilir
  serviceDisabled, // Telefonun GPS'i tamamen kapalı
  denied, // İzin henüz verilmedi (sorulabilir)
  deniedForever, // Kalıcı reddedildi (Ayarlara gitmek şart)
}

@lazySingleton
class LocationPermissionService {
  /// Mevcut konum servisi ve izin durumunu kontrol eder.
  /// Hasta rolü için [requireAlways] true gönderilmelidir.
  Future<LocationAccessStatus> checkStatus({bool requireAlways = false}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccessStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    return _mapPermission(permission, requireAlways: requireAlways);
  }

  /// Kullanıcıdan konum izni ister.
  /// [requireAlways] true ise önce kullanım sırası iznini, ardından her zaman iznini ister.
  Future<LocationAccessStatus> requestPermission({
    bool requireAlways = false,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationAccessStatus.serviceDisabled;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (requireAlways && permission == LocationPermission.whileInUse) {
      await Permission.locationAlways.request();
    }

    return checkStatus(requireAlways: requireAlways);
  }

  /// Cihazın uygulama izin ayarlarını veya konum ayarlarını açar.
  Future<void> openSettings() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  LocationAccessStatus _mapPermission(
    LocationPermission permission, {
    required bool requireAlways,
  }) {
    switch (permission) {
      case LocationPermission.always:
        return LocationAccessStatus.granted;
      case LocationPermission.whileInUse:
        return requireAlways
            ? LocationAccessStatus.denied
            : LocationAccessStatus.granted;
      case LocationPermission.deniedForever:
        return LocationAccessStatus.deniedForever;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationAccessStatus.denied;
    }
  }
}
