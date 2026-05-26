import 'package:equatable/equatable.dart';
import '../../../care_network/domain/entities/network_user.dart';
import '../../domain/entities/dashboard_summary.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {
  final List<NetworkUser>? patients;
  final String? loadingPatientId;

  const DashboardLoading({this.patients, this.loadingPatientId});

  @override
  List<Object?> get props => [patients, loadingPatientId];
}

class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final List<NetworkUser> patients;

  const DashboardLoaded({required this.summary, required this.patients});

  @override
  List<Object?> get props => [summary, patients];
}

class DashboardNoPatients extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;
  final List<NetworkUser>? patients;

  const DashboardError(this.message, {this.patients});

  @override
  List<Object?> get props => [message, patients];
}
