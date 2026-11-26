import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/location_tracking/domain/usecases/log_location_usecase.dart';

class LocationBgService {
  static const String _notificationChannelId = 'location_channel';
  static const int _foregroundNotificationId = 888;
  static bool _isInitialized = false;

  static Future<void> initializeService() async {
    if (_isInitialized) return;

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _notificationChannelId,
        'Hasta Konum Takibi',
        description:
            'Hastanın güvenliği için konum ve pil durumunu arka planda paylaşır.',
        importance: Importance.low,
      ),
    );

    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        autoStartOnBoot: false,
        isForegroundMode: true,
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'Hasta Takibi Aktif',
        initialNotificationContent:
            'Konumunuz güvenliğiniz için arka planda takip ediliyor.',
        foregroundServiceNotificationId: _foregroundNotificationId,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    _isInitialized = true;
  }

  static Future<void> startTrackingIfNeeded() async {
    await initializeService();
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
    }
  }

  static Future<void> stopTracking() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (isRunning) {
      service.invoke('stop');
    }
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  StreamSubscription<Position>? positionSubscription;
  Timer? heartbeatTimer;

  service.on('stop').listen((_) async {
    await positionSubscription?.cancel();
    heartbeatTimer?.cancel();
    await service.stopSelf();
  });

  await dotenv.load(fileName: '.env');
  if (!bgGetIt.isRegistered<LogLocationUseCase>()) {
    configureBackgroundDependencies();
  }

  final secureStorage = bgGetIt<FlutterSecureStorage>();
  if (!await _isActivePatientSession(secureStorage)) {
    debugPrint('LocationBgService: Aktif hasta oturumu yok, servis durduruluyor.');
    await service.stopSelf();
    return;
  }

  final logLocation = bgGetIt<LogLocationUseCase>();
  final battery = bgGetIt<Battery>();
  var lastSent = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> send(Position position, {bool force = false}) async {
    if (!force &&
        DateTime.now().difference(lastSent) < const Duration(seconds: 30)) {
      return;
    }
    if (!await _isActivePatientSession(secureStorage)) {
      await positionSubscription?.cancel();
      heartbeatTimer?.cancel();
      await service.stopSelf();
      return;
    }

    lastSent = DateTime.now();

    int? level;
    bool? charging;
    try {
      final rawLevel = await battery.batteryLevel;
      if (rawLevel >= 0 && rawLevel <= 100) {
        level = rawLevel;
      }
      final state = await battery.batteryState;
      charging = state == BatteryState.charging || state == BatteryState.full;
    } catch (e) {
      debugPrint('LocationBgService pil okunamadı: $e');
    }

    final result = await logLocation(
      LogLocationParams(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        batteryLevel: level,
        isCharging: charging,
      ),
    );
    result.fold(
      (f) => debugPrint('Konum gönderilemedi: ${f.message}'),
      (_) => debugPrint('Konum ve pil bilgisi gönderildi.'),
    );
  }

  // Servis başladığında ilk konumu beklemeden gönder
  try {
    final initialPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    await send(initialPosition, force: true);
  } catch (e) {
    debugPrint('İlk konum alınamadı: $e');
  }

  positionSubscription =
      Geolocator.getPositionStream(locationSettings: _locationSettings())
          .listen(send);

  // Hasta hareketsizken de veri ve pil durumu güncellensin
  heartbeatTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      await send(p);
    } catch (e) {
      debugPrint('Heartbeat konum alınamadı: $e');
    }
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    if (!bgGetIt.isRegistered<LogLocationUseCase>()) {
      configureBackgroundDependencies();
    }

    final secureStorage = bgGetIt<FlutterSecureStorage>();
    if (!await _isActivePatientSession(secureStorage)) {
      return true;
    }

    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );

    final battery = bgGetIt<Battery>();
    int? level;
    bool? charging;
    try {
      final rawLevel = await battery.batteryLevel;
      if (rawLevel >= 0 && rawLevel <= 100) {
        level = rawLevel;
      }
      final state = await battery.batteryState;
      charging = state == BatteryState.charging || state == BatteryState.full;
    } catch (_) {}

    await bgGetIt<LogLocationUseCase>()(
      LogLocationParams(
        latitude: p.latitude,
        longitude: p.longitude,
        accuracy: p.accuracy,
        batteryLevel: level,
        isCharging: charging,
      ),
    );
  } catch (e) {
    debugPrint('onIosBackground hatası: $e');
  }

  return true;
}

Future<bool> _isActivePatientSession(
  FlutterSecureStorage secureStorage,
) async {
  try {
    final token = await secureStorage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) return false;

    const roleClaimKey =
        'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
    final payload = JwtDecoder.decode(token);
    final rawRole =
        (payload[roleClaimKey] ?? payload['role'] ?? '')
            .toString()
            .toLowerCase();
    return rawRole == 'patient' || rawRole == '0';
  } catch (_) {
    return false;
  }
}

LocationSettings _locationSettings() {
  if (Platform.isAndroid) {
    return AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
    );
  }
  if (Platform.isIOS) {
    return AppleSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20,
      activityType: ActivityType.otherNavigation,
      pauseLocationUpdatesAutomatically: false,
      allowBackgroundLocationUpdates: true,
      showBackgroundLocationIndicator: true,
    );
  }
  return const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 20,
  );
}
