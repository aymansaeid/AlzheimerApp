import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

abstract class NotificationLocalDataSource {
  Future<void> init();
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
}

@LazySingleton(as: NotificationLocalDataSource)
class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _safeZoneChannel =
      AndroidNotificationChannel(
        'safezone_alerts_channel',
        'Güvenli Bölge Bildirimleri',
        description: 'Hasta güvenli bölge dışına çıktığında acil uyarı verir.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  @override
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Kullanıcı bildirime tıkladığında çalışacak yer
      },
    );

    // Android için kanalı oluştur
    final androidImplementation = _localPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImplementation?.createNotificationChannel(_safeZoneChannel);
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _safeZoneChannel.id,
      _safeZoneChannel.name,
      channelDescription: _safeZoneChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      ),
      payload: payload,
    );
  }
}
