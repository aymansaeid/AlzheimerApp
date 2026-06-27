import 'package:equatable/equatable.dart';
import '../../domain/entities/patient_dashboard.dart';

abstract class PatientDashboardState extends Equatable {
  const PatientDashboardState();

  @override
  List<Object?> get props => [];
}

class PatientDashboardInitial extends PatientDashboardState {
  const PatientDashboardInitial();
}

class PatientDashboardLoading extends PatientDashboardState {
  const PatientDashboardLoading();
}

class PatientDashboardLoaded extends PatientDashboardState {
  final PatientDashboard dashboardData;

  const PatientDashboardLoaded(this.dashboardData);

  @override
  List<Object?> get props => [dashboardData];
}

class PatientDashboardError extends PatientDashboardState {
  final String message;

  const PatientDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
