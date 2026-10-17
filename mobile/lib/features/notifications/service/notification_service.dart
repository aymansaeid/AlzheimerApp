import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

import '../../../core/di/injection.dart';
import '../domain/repository/notification_repository.dart';

@lazySingleton
class NotificationService {
  final NotificationRepository _repository;
  final FlutterSecureStorage _secureStorage;

  NotificationService(
    this._repository,
    this._secureStorage,
  );

  Future<void> initialize() async {
    // 1. Bildirim İzni İste
    final isGranted = await _repository.requestPermission();
    debugPrint('Notification Permission Granted: $isGranted');

    // 2. Token Değişimi Dinleyicisi
    _repository.onTokenRefresh.listen(_handleTokenRefresh);

    // 3. Uygulama ÖN PLANDAYKEN (Foreground) Gelen Mesajlar
    _repository.onForegroundMessage.listen(_handleForegroundMessage);

    // 4. Uygulama ARKAPLANDAYKEN Bildirime Tıklanarak Açılma
    _repository.onMessageOpenedApp.listen(_handleNotificationClick);
  }

  // Token yenilenirse ve kullanıcı login ise backend'e gönder
  Future<void> _handleTokenRefresh(String newToken) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token != null && token.isNotEmpty) {
      try {
        final authRepo = getIt<AuthRepository>();
        await authRepo.updateFcmToken(newToken);
        debugPrint('Yenilenen FCM token backend ile senkronize edildi.');
      } catch (e) {
        debugPrint('FCM Sync Error on refresh: $e');
      }
    }
  }

  // Kullanıcı uygulamayı kullanırken bildirim geldiğinde
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground Bildirim Alındı: ${message.data}');

    final type = message.data['type'];

    // 1. Senaryo: Güvenli Bölge İhlali (SAFEZONE_EXIT)
    if (type == 'SAFEZONE_EXIT') {
      final patientName = message.data['patientName'] ?? 'Takip edilen kişi';
      final zoneName = message.data['zoneName'] ?? 'Güvenli Alan';

      await _repository.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '⚠️ GÜVENLİ BÖLGE İHLALİ!',
        body: '$patientName adlı kişi $zoneName sınırları dışına çıktı!',
        payload: jsonEncode(message.data),
      );

      // Harita/takip ekranındaki SafeZoneBloc'a event fırlatılabilir:
      // getIt<SafeZoneBloc>().add(SafeZoneBreachedEvent(message.data));
    }
    // 2. Senaryo: İlaç Alma Gecikmesi Uyarısı (MEDICATION_MISSED)
    else if (type == 'MEDICATION_MISSED' || type == 'MEDICATION_DELAYED') {
      final patientName = message.data['patientName'] ?? 'Hasta';
      final medicineName = message.data['medicineName'] ?? 'İlacını';
      final scheduledTime = message.data['scheduledTime'] ?? '';

      final timeText = scheduledTime.isNotEmpty ? ' ($scheduledTime)' : '';

      await _repository.showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '💊 İLAÇ GECİKMESİ UYARISI!',
        body: '$patientName saat$timeText $medicineName dozunu henüz almadı!',
        payload: jsonEncode(message.data),
      );

      // Varsa hasta takip / ilaç takip Bloc'una event atılabilir:
      // getIt<MedicationBloc>().add(MedicationMissedEvent(message.data));
    }
    // 3. Senaryo: Admin Yetkisi Devri (ROLE_UPDATED)
    else if (type == 'ROLE_UPDATED' || type == 'ADMIN_GRANTED') {
      // getIt<AuthBloc>().add(const AuthEvent.refreshRole());
    }
    // Standart bildirim (eğer özel type eşleşmediyse ve notification alanı doluysa)
    else if (message.notification != null) {
      await _repository.showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'Bildirim',
        body: message.notification!.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  // Kullanıcı telefonun üst çekmecesindeki bildirime tıkladığında
  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('Bildirime tıklandı: ${message.data}');
    final type = message.data['type'];

    if (type == 'SAFEZONE_EXIT') {
      final patientId = message.data['patientId'];
      // Harita takip rotasına yönlendir
      // getIt<AppRouter>().push('/patient-tracking/$patientId');
    } else if (type == 'MEDICATION_MISSED' || type == 'MEDICATION_DELAYED') {
      final patientId = message.data['patientId'];
      // Hasta detayındaki ilaç takip sekmesine yönlendir
      // getIt<AppRouter>().push('/patient-medications/$patientId');
    }
  }
}
