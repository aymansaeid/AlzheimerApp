import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;
  final int accuracyMeters;
  final int? batteryLevel;
  final bool? isCharging;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters = 0,
    this.batteryLevel,
    this.isCharging,
  });

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        accuracyMeters,
        batteryLevel,
        isCharging,
      ];
}
