import 'package:equatable/equatable.dart';

abstract class PatientDashboardEvent extends Equatable {
  const PatientDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatientDashboardEvent extends PatientDashboardEvent {
  const LoadPatientDashboardEvent();
}

class DashboardMedicineTakenEvent extends PatientDashboardEvent {
  final String logId;
  final int status;

  const DashboardMedicineTakenEvent(this.logId, this.status);

  @override
  List<Object?> get props => [logId, status];
}
