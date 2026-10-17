import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationRepository {
  Future<bool> requestPermission();
  Future<String?> getDeviceToken();
  Stream<String> get onTokenRefresh;
  Stream<RemoteMessage> get onForegroundMessage;
  Stream<RemoteMessage> get onMessageOpenedApp;
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
}
