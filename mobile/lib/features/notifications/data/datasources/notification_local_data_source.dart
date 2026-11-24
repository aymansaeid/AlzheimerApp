import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../medication/domain/entities/medicine.dart';

abstract class NotificationLocalDataSource {
  Future<void> init();
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
  Future<void> syncMedicationReminders(List<Medicine> medications);
  Future<void> cancelMedicationReminders(String medicineId);
  Future<void> cancelAllMedicationReminders();
}

@LazySingleton(as: NotificationLocalDataSource)
class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _medType = 'MED_REMINDER';

  static const _safeZoneChannel = AndroidNotificationChannel(
    'safezone_alerts_channel',
    'Güvenli Bölge Bildirimleri',
    description: 'Hasta güvenli bölge dışına çıktığında acil uyarı verir.',
    importance: Importance.max,
  );

  static const _medicationChannel = AndroidNotificationChannel(
    'medication_reminders_channel',
    'İlaç Hatırlatıcıları',
    description:
        'Zamanı gelen ilaçlar için sesli ve yüksek öncelikli alarmlar.',
    importance: Importance.max,
  );

  @override
  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (res) =>
          debugPrint('Clicked: ${res.payload}'),
    );

    final androidPlugin = _localPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_safeZoneChannel);
    await androidPlugin?.createNotificationChannel(_medicationChannel);
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _safeZoneChannel.id,
          _safeZoneChannel.name,
          channelDescription: _safeZoneChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  @override
  Future<void> syncMedicationReminders(List<Medicine> medications) async {
    try {
      final pending = await _localPlugin.pendingNotificationRequests();
      final existingMap = <int, PendingNotificationRequest>{
        for (final req in pending)
          if (_isMedicationPayload(req.payload)) req.id: req,
      };

      final now = DateTime.now();
      final expectedIds = <int>{};

      for (final med in medications) {
        if (!med.isActive ||
            (med.endDate != null && med.endDate!.isBefore(now))) {
          continue;
        }

        final parts = med.scheduleTime.trim().split(':');
        if (parts.length < 2) {
          continue;
        }
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) {
          continue;
        }

        final id = _generateId(med.id, med.scheduleTime);
        expectedIds.add(id);

        final title = '💊 İlaç Vakti: ${med.name}';
        final body = med.dosage.isNotEmpty
            ? '${med.dosage} alma zamanı. ${med.instructions}'.trim()
            : 'İlacınızı alma zamanı. ${med.instructions}'.trim();
        final payload = jsonEncode({
          'type': _medType,
          'medicineId': med.id,
          'scheduleTime': med.scheduleTime,
        });

        final existing = existingMap[id];
        final isUnchanged =
            existing != null &&
            existing.title == title &&
            existing.body == body &&
            existing.payload == payload;

        if (!isUnchanged) {
          if (existing != null) await _localPlugin.cancel(id: id);
          await _scheduleDaily(id, title, body, hour, minute, payload);
        }
      }

      // Güncel listede olmayan eski bildirimleri sil
      for (final existingId in existingMap.keys) {
        if (!expectedIds.contains(existingId)) {
          await _localPlugin.cancel(id: existingId);
        }
      }
    } catch (e) {
      debugPrint('İlaç senkronizasyon hatası: $e');
    }
  }

  @override
  Future<void> cancelMedicationReminders(String medicineId) async {
    final pending = await _localPlugin.pendingNotificationRequests();
    for (final req in pending) {
      if (_isMedicationPayload(req.payload, targetMedicineId: medicineId)) {
        await _localPlugin.cancel(id: req.id);
      }
    }
  }

  @override
  Future<void> cancelAllMedicationReminders() async {
    final pending = await _localPlugin.pendingNotificationRequests();
    for (final req in pending) {
      if (_isMedicationPayload(req.payload)) {
        await _localPlugin.cancel(id: req.id);
      }
    }
  }

  Future<void> _scheduleDaily(
    int id,
    String title,
    String body,
    int hour,
    int minute,
    String payload,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _localPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _medicationChannel.id,
          _medicationChannel.name,
          channelDescription: _medicationChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  bool _isMedicationPayload(String? payload, {String? targetMedicineId}) {
    if (payload == null) return false;
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      if (map['type'] != _medType) return false;
      if (targetMedicineId != null && map['medicineId'] != targetMedicineId) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  int _generateId(String medicineId, String scheduleTime) =>
      ('$medicineId-$scheduleTime'.hashCode.abs()) % 2147483647;
}
