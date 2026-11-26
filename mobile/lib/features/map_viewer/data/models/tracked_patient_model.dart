import 'package:latlong2/latlong.dart';

import '../../domain/entities/patient_entity.dart';

class TrackedPatientModel extends PatientEntity {
  const TrackedPatientModel({
    required super.id,
    required super.name,
    super.avatarUrl,
    super.phoneNumber,
    super.currentLocation,
    super.lastUpdatedAt,
    super.batteryLevel,
    super.isCharging = false,
    super.isOutOfSafeZone = false,
    super.safeZone,
  });

  factory TrackedPatientModel.fromLatestJson(Map<String, dynamic> json) {
    final patientId = (json['patientId'] ?? json['id'] ?? '').toString();
    final fullName = (json['fullName'] ?? json['name'] ?? '').toString();
    final profilePhotoUrl =
        (json['profilePhotoUrl'] ?? json['avatarUrl'])?.toString();
    final phone = (json['phone'] ?? json['phoneNumber'])?.toString();

    final latestRaw = json['latestLocation'];
    LatLng? location;
    DateTime? updatedAt;
    bool isOut = false;
    int? batteryLevel;
    bool isCharging = false;

    if (latestRaw is Map<String, dynamic>) {
      final lat = (latestRaw['latitude'] as num?)?.toDouble();
      final lng = (latestRaw['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        location = LatLng(lat, lng);
      }

      final tsRaw = latestRaw['timestamp'] ?? latestRaw['recordedAt'];
      if (tsRaw != null) {
        updatedAt = DateTime.tryParse(tsRaw.toString())?.toLocal();
      }

      final isInside = latestRaw['isInsideSafeZone'] as bool?;
      if (isInside != null) {
        isOut = !isInside;
      } else if (latestRaw['isOutsideZone'] is bool) {
        isOut = latestRaw['isOutsideZone'] as bool;
      }

      batteryLevel = (latestRaw['batteryLevel'] as num?)?.toInt();
      isCharging = latestRaw['isCharging'] as bool? ?? false;
    }

    return TrackedPatientModel(
      id: patientId,
      name: fullName,
      avatarUrl: profilePhotoUrl,
      phoneNumber: phone,
      currentLocation: location,
      lastUpdatedAt: updatedAt,
      batteryLevel: batteryLevel,
      isCharging: isCharging,
      isOutOfSafeZone: isOut,
    );
  }
}
