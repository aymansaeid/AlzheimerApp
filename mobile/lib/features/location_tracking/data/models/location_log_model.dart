import 'package:mobile/features/location_tracking/domain/entities/loation_entity.dart';

class LocationLogModel extends LocationEntity {
  const LocationLogModel({
    required super.patientId,
    required super.latitude,
    required super.longitude,
    super.accuracyMeters = 0,
  });

  // Backend'e gönderilecek JSON formatı (Ekran görüntünüzdeki şemaya sadık kalınarak)
  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracyMeters': accuracyMeters,
    };
  }

  // Gerekirse cihazdan gelen veriyi modele çevirmek için fabrikasyon metodu
  factory LocationLogModel.fromDevice({
    required String patientId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) {
    return LocationLogModel(
      patientId: patientId,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracy?.round() ?? 0,
    );
  }
}
