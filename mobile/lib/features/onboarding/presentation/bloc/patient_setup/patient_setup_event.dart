import 'package:equatable/equatable.dart';

abstract class PatientSetupEvent extends Equatable {
  const PatientSetupEvent();

  @override
  List<Object?> get props => [];
}

class CheckAdminStatus extends PatientSetupEvent {
  final String patientId;

  const CheckAdminStatus(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class GenerateInviteCode extends PatientSetupEvent {
  final String patientId;

  const GenerateInviteCode(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class RefreshAdminStatus extends PatientSetupEvent {
  final String patientId;

  const RefreshAdminStatus(this.patientId);

  @override
  List<Object?> get props => [patientId];
}
