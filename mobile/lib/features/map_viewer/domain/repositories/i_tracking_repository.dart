import 'package:fpdart/fpdart.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/core/errors/failures.dart';

import '../entities/patient_entity.dart';
import '../entities/safe_zone_entity.dart';

abstract class ITrackingRepository {
  /// Takip edilen tüm hastaların anlık durumunu stream olarak yayar.
  Stream<List<PatientEntity>> watchPatients();

  /// İlk açılışta REST ile son konumları çeker ve SignalR canlı hub'ına bağlanır.
  Future<Either<Failure, List<PatientEntity>>> loadInitialPatientsAndConnectHub();

  /// Belirli bir hastaya Safe-Zone tanımlar (POST) veya mevcut bölgeyi günceller (PUT).
  Future<Either<Failure, void>> setSafeZone({
    required String patientId,
    required SafeZoneEntity safeZone,
  });

  /// Belirli bir hastanın Safe-Zone tanımlamasını siler (DELETE).
  Future<Either<Failure, void>> removeSafeZone(String patientId);

  /// Takipçinin kendi cihaz konumunu stream olarak verir.
  Stream<LatLng> getFollowerLocationStream();

  /// Harita ekranından çıkarken SignalR bağlantısını kapatır.
  Future<void> disconnectRealtime();
}
