import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/safe_zone_entity.dart';
import '../../domain/usecases/disconnect_tracking_usecase.dart';
import '../../domain/usecases/get_follower_location_stream_usecase.dart';
import '../../domain/usecases/load_tracked_patients_usecase.dart';
import '../../domain/usecases/remove_safe_zone_usecase.dart';
import '../../domain/usecases/set_safe_zone_usecase.dart';
import '../../domain/usecases/watch_tracked_patients_usecase.dart';
import 'tracker_map_event.dart';
import 'tracker_map_state.dart';

@injectable
class TrackerMapBloc extends Bloc<TrackerMapEvent, TrackerMapState> {
  final WatchTrackedPatientsUseCase _watchTrackedPatientsUseCase;
  final LoadTrackedPatientsUseCase _loadTrackedPatientsUseCase;
  final DisconnectTrackingUseCase _disconnectTrackingUseCase;
  final SetSafeZoneUseCase _setSafeZoneUseCase;
  final RemoveSafeZoneUseCase _removeSafeZoneUseCase;
  final GetFollowerLocationStreamUseCase _getFollowerLocationStreamUseCase;

  bool _streamsStarted = false;

  TrackerMapBloc(
    this._watchTrackedPatientsUseCase,
    this._loadTrackedPatientsUseCase,
    this._disconnectTrackingUseCase,
    this._setSafeZoneUseCase,
    this._removeSafeZoneUseCase,
    this._getFollowerLocationStreamUseCase,
  ) : super(const TrackerMapState()) {
    on<TrackerMapStarted>(_onStarted);
    on<TrackerMapRefreshRequested>(_onRefreshRequested);
    on<PatientSelected>(_onPatientSelected);
    on<SafeZoneEditModeToggled>(_onSafeZoneEditModeToggled);
    on<SafeZoneSaved>(_onSafeZoneSaved);
    on<SafeZoneRemoved>(_onSafeZoneRemoved);
    on<TrackerMapErrorCleared>(_onErrorCleared);
  }

  @override
  Future<void> close() {
    unawaited(_disconnectTrackingUseCase());
    return super.close();
  }

  Future<void> _onStarted(
    TrackerMapStarted event,
    Emitter<TrackerMapState> emit,
  ) async {
    if (_streamsStarted) {
      await _loadPatients(emit, selectPatientId: event.initialPatientId);
      return;
    }

    _streamsStarted = true;
    emit(
      state.copyWith(
        status: TrackerMapStatus.loading,
        selectedPatientId: event.initialPatientId,
        clearErrorMessage: true,
      ),
    );

    await _loadPatients(emit, selectPatientId: event.initialPatientId);

    // İki farklı stream'i (Hastalar + SignalR ve Takipçi Konumu) paralel dinliyoruz
    await Future.wait([
      emit.forEach<List<PatientEntity>>(
        _watchTrackedPatientsUseCase(),
        onData: (patients) => state.copyWith(
          status: TrackerMapStatus.loaded,
          patients: patients,
        ),
        onError: (error, _) => state.copyWith(
          status: TrackerMapStatus.failure,
          errorMessage: error.toString(),
        ),
      ),
      emit.forEach<LatLng>(
        _getFollowerLocationStreamUseCase(),
        onData: (location) => state.copyWith(followerLocation: location),
      ),
    ]);
  }

  Future<void> _onRefreshRequested(
    TrackerMapRefreshRequested event,
    Emitter<TrackerMapState> emit,
  ) async {
    await _loadPatients(emit, selectPatientId: event.selectPatientId);
  }

  Future<void> _loadPatients(
    Emitter<TrackerMapState> emit, {
    String? selectPatientId,
  }) async {
    final result = await _loadTrackedPatientsUseCase();
    result.fold(
      (failure) {
        if (state.patients.isEmpty) {
          emit(
            state.copyWith(
              status: TrackerMapStatus.failure,
              errorMessage: failure.message,
            ),
          );
        } else {
          emit(state.copyWith(actionErrorMessage: failure.message));
        }
      },
      (patients) {
        emit(
          state.copyWith(
            status: TrackerMapStatus.loaded,
            patients: patients,
            selectedPatientId: selectPatientId ?? state.selectedPatientId,
            clearErrorMessage: true,
          ),
        );
      },
    );
  }

  void _onPatientSelected(
    PatientSelected event,
    Emitter<TrackerMapState> emit,
  ) {
    if (event.patientId == null) {
      emit(
        state.copyWith(
          clearSelectedPatient: true,
          isEditingSafeZone: false,
        ),
      );
    } else {
      // Başka bir hastaya geçilirse safe-zone düzenleme modunu kapat
      final isSamePatient = state.selectedPatientId == event.patientId;
      emit(
        state.copyWith(
          selectedPatientId: event.patientId,
          isEditingSafeZone: isSamePatient ? state.isEditingSafeZone : false,
        ),
      );
    }
  }

  void _onSafeZoneEditModeToggled(
    SafeZoneEditModeToggled event,
    Emitter<TrackerMapState> emit,
  ) {
    if (state.selectedPatientId == null) return;
    emit(state.copyWith(isEditingSafeZone: event.isEditing));
  }

  Future<void> _onSafeZoneSaved(
    SafeZoneSaved event,
    Emitter<TrackerMapState> emit,
  ) async {
    final patient = state.selectedPatient;
    if (patient == null) return;

    final existingZone = patient.safeZone;
    final newSafeZone = SafeZoneEntity(
      id: existingZone?.id,
      name: existingZone?.name ?? '${patient.name} Güvenli Bölgesi',
      center: event.center,
      radiusInMeters: event.radiusInMeters,
      isActive: true,
    );

    final result = await _setSafeZoneUseCase(
      patientId: patient.id,
      safeZone: newSafeZone,
    );

    result.fold(
      (failure) => emit(state.copyWith(actionErrorMessage: failure.message)),
      (_) => emit(state.copyWith(isEditingSafeZone: false)),
    );
  }

  Future<void> _onSafeZoneRemoved(
    SafeZoneRemoved event,
    Emitter<TrackerMapState> emit,
  ) async {
    final patientId = state.selectedPatientId;
    if (patientId == null) return;

    final result = await _removeSafeZoneUseCase(patientId);
    result.fold(
      (failure) => emit(state.copyWith(actionErrorMessage: failure.message)),
      (_) => emit(state.copyWith(isEditingSafeZone: false)),
    );
  }

  void _onErrorCleared(
    TrackerMapErrorCleared event,
    Emitter<TrackerMapState> emit,
  ) {
    emit(state.copyWith(clearActionError: true));
  }
}
