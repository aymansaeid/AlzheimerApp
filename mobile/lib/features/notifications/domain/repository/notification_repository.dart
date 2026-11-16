import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile/features/medication/domain/entities/medicine.dart';

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
  Future<bool> checkPermissionStatus();
  Future<bool> isPermissionPermanentlyDenied(); // Kalıcı red kontrolü için
  Future<bool> openNotificationSettings();
  Future<void> syncMedicationReminders(List<Medicine> medications);
  Future<void> cancelMedicationReminders(String medicineId);
}
