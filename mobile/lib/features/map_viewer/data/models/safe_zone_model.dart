import 'package:latlong2/latlong.dart';

import '../../domain/entities/safe_zone_entity.dart';

class SafeZoneModel extends SafeZoneEntity {
  const SafeZoneModel({
    super.id,
    super.name = 'Güvenli Bölge',
    required super.center,
    required super.radiusInMeters,
    super.isActive = true,
  });

  factory SafeZoneModel.fromJson(Map<String, dynamic> json) {
    return SafeZoneModel(
      id: json['id']?.toString(),
      name: (json['name'] ?? 'Güvenli Bölge').toString(),
      center: LatLng(
        (json['centerLat'] as num).toDouble(),
        (json['centerLng'] as num).toDouble(),
      ),
      radiusInMeters: (json['radiusMeters'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  factory SafeZoneModel.fromEntity(SafeZoneEntity entity) {
    return SafeZoneModel(
      id: entity.id,
      name: entity.name,
      center: entity.center,
      radiusInMeters: entity.radiusInMeters,
      isActive: entity.isActive,
    );
  }

  Map<String, dynamic> toCreateJson(String patientId) {
    return {
      'patientId': patientId,
      'name': name,
      'centerLat': center.latitude,
      'centerLng': center.longitude,
      'radiusMeters': radiusInMeters.round(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'centerLat': center.latitude,
      'centerLng': center.longitude,
      'radiusMeters': radiusInMeters.round(),
      'isActive': isActive,
    };
  }
}
