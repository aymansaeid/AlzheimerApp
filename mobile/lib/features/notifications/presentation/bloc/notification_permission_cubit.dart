import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/features/notifications/domain/repository/notification_repository.dart';
import 'notification_permission_state.dart';

@injectable
class NotificationPermissionCubit extends Cubit<NotificationPermissionState> {
  final NotificationRepository _notificationRepository;

  NotificationPermissionCubit(
    this._notificationRepository,
  ) : super(const NotificationPermissionInitial());

  /// Mevcut bildirim izin durumunu kontrol eder.
  Future<void> checkPermission() async {
    emit(const NotificationPermissionChecking());
    final isGranted = await _notificationRepository.checkPermissionStatus();
    if (isGranted) {
      emit(const NotificationPermissionGranted());
    } else {
      final isPermanent = await _notificationRepository
          .isPermissionPermanentlyDenied();
      emit(NotificationPermissionDenied(isPermanentlyDenied: isPermanent));
    }
  }

  /// Kullanıcıdan sistem seviyesinde bildirim izni ister.
  Future<void> requestPermission() async {
    final isPermanentBefore = await _notificationRepository
        .isPermissionPermanentlyDenied();

    // Eğer kalıcı olarak reddedilmişse doğrudan uygulama ayarlarına yönlendir
    if (isPermanentBefore) {
      await openSettings();
      return;
    }

    final isGranted = await _notificationRepository.requestPermission();
    if (isGranted) {
      emit(const NotificationPermissionGranted());
    } else {
      final isPermanentAfter = await _notificationRepository
          .isPermissionPermanentlyDenied();

      emit(
        NotificationPermissionDenied(isPermanentlyDenied: isPermanentAfter),
      );

      // Kullanıcı kalıcı olarak reddettiyse ayarları aç
      if (isPermanentAfter) {
        await openSettings();
      }
    }
  }

  /// Telefonun uygulama bildirim ayarlarını açar.
  Future<void> openSettings() async {
    await _notificationRepository.openNotificationSettings();
  }
}
