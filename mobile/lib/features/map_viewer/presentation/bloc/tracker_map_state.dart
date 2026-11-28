import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/safe_zone_entity.dart';

enum TrackerMapStatus { initial, loading, loaded, failure }

class TrackerMapState extends Equatable {
  final TrackerMapStatus status;
  final List<PatientEntity> patients;
  final String? selectedPatientId;
  final bool isEditingSafeZone;
  final SafeZoneEntity? editingSafeZone;
  final LatLng? followerLocation;
  final String? errorMessage;
  final String? actionErrorMessage;

  const TrackerMapState({
    this.status = TrackerMapStatus.initial,
    this.patients = const [],
    this.selectedPatientId,
    this.isEditingSafeZone = false,
    this.editingSafeZone,
    this.followerLocation,
    this.errorMessage,
    this.actionErrorMessage,
  });

  /// Şu an seçili olan hastanın güncel nesnesini döndürür
  PatientEntity? get selectedPatient {
    if (selectedPatientId == null) return null;
    try {
      return patients.firstWhere((p) => p.id == selectedPatientId);
    } catch (_) {
      return null;
    }
  }

  TrackerMapState copyWith({
    TrackerMapStatus? status,
    List<PatientEntity>? patients,
    String? selectedPatientId,
    bool clearSelectedPatient = false,
    bool? isEditingSafeZone,
    SafeZoneEntity? editingSafeZone,
    bool clearEditingSafeZone = false,
    LatLng? followerLocation,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? actionErrorMessage,
    bool clearActionError = false,
  }) {
    return TrackerMapState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      selectedPatientId: clearSelectedPatient
          ? null
          : (selectedPatientId ?? this.selectedPatientId),
      isEditingSafeZone: isEditingSafeZone ?? this.isEditingSafeZone,
      editingSafeZone: clearEditingSafeZone
          ? null
          : (editingSafeZone ?? this.editingSafeZone),
      followerLocation: followerLocation ?? this.followerLocation,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      actionErrorMessage: clearActionError
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        patients,
        selectedPatientId,
        isEditingSafeZone,
        editingSafeZone,
        followerLocation,
        errorMessage,
        actionErrorMessage,
      ];
}
