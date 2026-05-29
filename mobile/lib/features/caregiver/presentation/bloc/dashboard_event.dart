import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final String? patientId;

  const LoadDashboard(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class SelectPatient extends DashboardEvent {
  final String patientId;

  const SelectPatient(this.patientId);

  @override
  List<Object?> get props => [patientId];
}
