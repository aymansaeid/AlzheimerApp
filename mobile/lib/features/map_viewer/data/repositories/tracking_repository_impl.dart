import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/core/errors/exceptions.dart';
import 'package:mobile/core/errors/failures.dart';

import '../../../location_tracking/data/services/location_permission_service.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/safe_zone_entity.dart';
import '../../domain/repositories/i_tracking_repository.dart';
import '../datasources/location_hub_data_source.dart';
import '../datasources/tracking_remote_data_source.dart';
import '../models/safe_zone_model.dart';

@LazySingleton(as: ITrackingRepository)
class TrackingRepositoryImpl implements ITrackingRepository {
  final TrackingRemoteDataSource _remoteDataSource;
  final LocationHubDataSource _hubDataSource;
  final LocationPermissionService _permissionService;

  final StreamController<List<PatientEntity>> _patientsController =
      StreamController<List<PatientEntity>>.broadcast();
  final Distance _distanceCalc = const Distance();

  List<PatientEntity> _patients = [];
  StreamSubscription<Map<String, dynamic>>? _hubSubscription;

  TrackingRepositoryImpl(
    this._remoteDataSource,
    this._hubDataSource,
    this._permissionService,
  );

  @override
  Stream<List<PatientEntity>> watchPatients() async* {
    if (_patients.isNotEmpty) {
      yield List.unmodifiable(_patients);
    }
    yield* _patientsController.stream;
  }

  @override
  Future<Either<Failure, List<PatientEntity>>>
      loadInitialPatientsAndConnectHub() async {
    try {
      final remotePatients = await _remoteDataSource.getLatestPatients();

      _patients = remotePatients;
      _patientsController.add(List.unmodifiable(_patients));

      await _hubSubscription?.cancel();
      _hubSubscription = _hubDataSource.locationUpdates.listen(_onHubUpdate);

      try {
        await _hubDataSource.connectAndSubscribe(
          _patients.map((p) => p.id),
        );
      } catch (e) {
        debugPrint('TrackingRepositoryImpl: SignalR bağlantı hatası: $e');
      }

      return Right(List.unmodifiable(_patients));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  void _onHubUpdate(Map<String, dynamic> payload) {
    final patientId = payload['patientId']?.toString();
    if (patientId == null || patientId.isEmpty) return;

    final lat = (payload['latitude'] as num?)?.toDouble();
    final lng = (payload['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return;

    final recordedAtRaw = payload['recordedAt'];
    final recordedAt = recordedAtRaw != null
        ? DateTime.tryParse(recordedAtRaw.toString())?.toLocal()
        : DateTime.now();

    final isOutsideZone = payload['isOutsideZone'] as bool?;
    final batteryLevel = (payload['batteryLevel'] as num?)?.toInt();
    final isCharging = payload['isCharging'] as bool?;

    bool updated = false;
    _patients = _patients.map((patient) {
      if (patient.id != patientId) return patient;
      updated = true;
      return patient.copyWith(
        currentLocation: LatLng(lat, lng),
        lastUpdatedAt: recordedAt ?? patient.lastUpdatedAt,
        isOutOfSafeZone: isOutsideZone ?? patient.isOutOfSafeZone,
        batteryLevel: batteryLevel ?? patient.batteryLevel,
        isCharging: isCharging ?? patient.isCharging,
      );
    }).toList();

    if (updated) {
      _patientsController.add(List.unmodifiable(_patients));
    }
  }

  bool _isOutsideAllSafeZones(LatLng? location, List<SafeZoneEntity> zones) {
    if (location == null || zones.isEmpty) return false;
    final isInsideAny = zones.any(
      (z) => _distanceCalc.as(LengthUnit.Meter, z.center, location) <=
          z.radiusInMeters,
    );
    return !isInsideAny;
  }

  @override
  Future<Either<Failure, void>> setSafeZone({
    required String patientId,
    required SafeZoneEntity safeZone,
  }) async {
    try {
      final requestModel = SafeZoneModel.fromEntity(safeZone);
      final existingId = safeZone.id;
      late final SafeZoneModel savedZone;

      if (existingId != null && existingId.isNotEmpty) {
        await _remoteDataSource.updateSafeZone(
          safeZoneId: existingId,
          safeZone: requestModel,
        );
        savedZone = SafeZoneModel(
          id: existingId,
          name: requestModel.name,
          center: requestModel.center,
          radiusInMeters: requestModel.radiusInMeters,
          isActive: requestModel.isActive,
        );
      } else {
        savedZone = await _remoteDataSource.createSafeZone(
          patientId: patientId,
          safeZone: requestModel,
        );
      }

      _patients = _patients.map((patient) {
        if (patient.id != patientId) return patient;

        final updatedZones = List<SafeZoneEntity>.from(patient.safeZones);
        final idx = updatedZones.indexWhere((z) => z.id == savedZone.id);
        if (idx >= 0) {
          updatedZones[idx] = savedZone;
        } else {
          updatedZones.add(savedZone);
        }

        final isOut = _isOutsideAllSafeZones(
          patient.currentLocation,
          updatedZones,
        );

        return patient.copyWith(
          safeZones: updatedZones,
          isOutOfSafeZone: isOut,
        );
      }).toList();

      _patientsController.add(List.unmodifiable(_patients));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeSafeZone({
    required String patientId,
    required String safeZoneId,
  }) async {
    try {
      await _remoteDataSource.deleteSafeZone(safeZoneId);

      _patients = _patients.map((patient) {
        if (patient.id != patientId) return patient;

        final updatedZones = patient.safeZones
            .where((z) => z.id != safeZoneId)
            .toList();
        final isOut = _isOutsideAllSafeZones(
          patient.currentLocation,
          updatedZones,
        );

        return patient.copyWith(
          safeZones: updatedZones,
          isOutOfSafeZone: isOut,
        );
      }).toList();

      _patientsController.add(List.unmodifiable(_patients));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<LatLng> getFollowerLocationStream() async* {
    try {
      final status =
          await _permissionService.requestPermission(requireAlways: false);
      if (status != LocationAccessStatus.granted) {
        return;
      }

      final currentPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      yield LatLng(currentPos.latitude, currentPos.longitude);

      yield* Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
        ),
      ).map((pos) => LatLng(pos.latitude, pos.longitude));
    } catch (e) {
      debugPrint('TrackingRepositoryImpl: Takipçi konumu alınamadı: $e');
    }
  }

  @override
  Future<void> disconnectRealtime() async {
    await _hubSubscription?.cancel();
    _hubSubscription = null;
    await _hubDataSource.disconnect();
  }
}
