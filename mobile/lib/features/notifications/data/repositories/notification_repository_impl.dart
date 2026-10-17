import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repository/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';
import '../datasources/notification_remote_data_source.dart';

@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;

  NotificationRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<bool> requestPermission() => _remoteDataSource.requestPermission();

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
    return _localDataSource.showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );
  }
}
