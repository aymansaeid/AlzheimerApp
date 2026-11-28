import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final String? patientId;
  final bool silent;

  const LoadDashboard(this.patientId, {this.silent = false});

  @override
  List<Object?> get props => [patientId, silent];
}

class RefreshDashboardIfStale extends DashboardEvent {
  final Duration staleDuration;

  const RefreshDashboardIfStale({
    this.staleDuration = const Duration(minutes: 1),
  });

  @override
  List<Object?> get props => [staleDuration];
}

class SelectPatient extends DashboardEvent {
  final String patientId;

  const SelectPatient(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class ResetDashboard extends DashboardEvent {}

/// Refreshes only the followed patients list (`/api/Follower/my-patients`)
/// without re-fetching dashboard summary or care team endpoints.
class RefreshFollowedPatients extends DashboardEvent {
  const RefreshFollowedPatients();
}

/// Updates a single patient's `isPrimaryAdmin` flag locally without network calls.
class UpdateLocalPatientAdminStatus extends DashboardEvent {
  final String patientId;
  final bool isPrimaryAdmin;

  const UpdateLocalPatientAdminStatus({
    required this.patientId,
    required this.isPrimaryAdmin,
  });

  @override
  List<Object?> get props => [patientId, isPrimaryAdmin];
}

