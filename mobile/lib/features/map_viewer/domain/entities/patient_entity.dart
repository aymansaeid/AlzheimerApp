import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import 'safe_zone_entity.dart';

class PatientEntity extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? phoneNumber;
  final LatLng? currentLocation;
  final DateTime? lastUpdatedAt;
  final int? batteryLevel;
  final bool isCharging;
  final bool isOutOfSafeZone;
  final SafeZoneEntity? safeZone;

  const PatientEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.phoneNumber,
    this.currentLocation,
    this.lastUpdatedAt,
    this.batteryLevel,
    this.isCharging = false,
    this.isOutOfSafeZone = false,
    this.safeZone,
  });

  PatientEntity copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? phoneNumber,
    LatLng? currentLocation,
    bool clearCurrentLocation = false,
    DateTime? lastUpdatedAt,
    int? batteryLevel,
    bool? isCharging,
    bool? isOutOfSafeZone,
    SafeZoneEntity? safeZone,
    bool clearSafeZone = false,
  }) {
    return PatientEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currentLocation: clearCurrentLocation
          ? null
          : (currentLocation ?? this.currentLocation),
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isCharging: isCharging ?? this.isCharging,
      isOutOfSafeZone: isOutOfSafeZone ?? this.isOutOfSafeZone,
      safeZone: clearSafeZone ? null : (safeZone ?? this.safeZone),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        phoneNumber,
        currentLocation,
        lastUpdatedAt,
        batteryLevel,
        isCharging,
        isOutOfSafeZone,
        safeZone,
      ];
}
