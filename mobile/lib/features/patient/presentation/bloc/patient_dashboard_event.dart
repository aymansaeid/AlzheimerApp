import 'package:equatable/equatable.dart';

abstract class PatientDashboardEvent extends Equatable {
  const PatientDashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadPatientDashboardEvent extends PatientDashboardEvent {
  const LoadPatientDashboardEvent();
}
