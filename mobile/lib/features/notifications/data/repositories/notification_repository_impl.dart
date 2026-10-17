import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/features/medication/domain/entities/medicine.dart';
import '../../domain/repository/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';
import '../datasources/notification_remote_data_source.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationRepository _notificationRepository;

  NotificationRepositoryImpl(
    this._remoteDataSource,
    this._notificationRepository,
  );

  @override
  Future<bool> requestPermission() async {
    // Hem sistem iznini hem FCM iznini ister
    final status = await ph.Permission.notification.request();
    if (status.isGranted) {
      await _remoteDataSource.requestPermission();
      return true;
    }
    return false;
  }

  @override
  Future<String?> getDeviceToken() => _remoteDataSource.getToken();

  @override
  Stream<String> get onTokenRefresh => _remoteDataSource.onTokenRefresh;

  @override
  Stream<RemoteMessage> get onForegroundMessage =>
      _remoteDataSource.onForegroundMessage;

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      _remoteDataSource.onMessageOpenedApp;

  @override
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) {
    return _notificationRepository.showLocalNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );
  }

  @override
  Future<bool> checkPermissionStatus() async {
    final status = await ph.Permission.notification.status;
    return status.isGranted;
  }

  @override
  Future<bool> isPermissionPermanentlyDenied() async {
    final status = await ph.Permission.notification.status;
    return status.isPermanentlyDenied || status.isRestricted;
  }

  @override
  Future<bool> openNotificationSettings() async {
    return await ph.openAppSettings();
  }

  @override
  Future<void> syncMedicationReminders(List<Medicine> medications) {
    return _notificationRepository.syncMedicationReminders(medications);
  }

  @override
  Future<void> cancelMedicationReminders(String medicineId) {
    return _notificationRepository.cancelMedicationReminders(medicineId);
  }
}
