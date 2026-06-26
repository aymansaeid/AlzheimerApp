import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String patientId;
  final double latitude;
  final double longitude;
  final int accuracyMeters;

  const LocationEntity({
    required this.patientId,
    required this.latitude,
    required this.longitude,
    this.accuracyMeters = 0,
  });

  @override
  List<Object?> get props => [patientId, latitude, longitude, accuracyMeters];
}
