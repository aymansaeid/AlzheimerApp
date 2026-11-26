import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class SafeZoneEntity extends Equatable {
  final String? id;
  final String name;
  final LatLng center;
  final double radiusInMeters;
  final bool isActive;

  const SafeZoneEntity({
    this.id,
    this.name = 'Güvenli Bölge',
    required this.center,
    required this.radiusInMeters,
    this.isActive = true,
  });

  SafeZoneEntity copyWith({
    String? id,
    String? name,
    LatLng? center,
    double? radiusInMeters,
    bool? isActive,
  }) {
    return SafeZoneEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      center: center ?? this.center,
      radiusInMeters: radiusInMeters ?? this.radiusInMeters,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, center, radiusInMeters, isActive];
}
