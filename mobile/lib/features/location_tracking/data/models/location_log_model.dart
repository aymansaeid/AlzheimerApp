import 'package:mobile/features/location_tracking/domain/entities/location_entity.dart';

class LocationLogModel extends LocationEntity {
  const LocationLogModel({
    required super.latitude,
    required super.longitude,
    super.accuracyMeters = 0,
    super.batteryLevel,
    super.isCharging,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
      'batteryLevel': batteryLevel,
      'isCharging': isCharging,
    };
  }

  factory LocationLogModel.fromDevice({
    required double latitude,
    required double longitude,
    double? accuracy,
    int? batteryLevel,
    bool? isCharging,
  }) {
    final validBatteryLevel =
        batteryLevel != null && batteryLevel >= 0 && batteryLevel <= 100
            ? batteryLevel
            : null;

    return LocationLogModel(
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracy?.round() ?? 0,
      batteryLevel: validBatteryLevel,
      isCharging: isCharging,
    );
  }
}
