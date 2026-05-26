import 'package:equatable/equatable.dart';
import '../../../domain/entities/invite_response.dart';

abstract class PatientSetupState extends Equatable {
  const PatientSetupState();

  @override
  List<Object?> get props => [];
}

class PatientSetupInitial extends PatientSetupState {}

class PatientSetupLoading extends PatientSetupState {}

class PatientSetupHasAdminInitial extends PatientSetupState {
  const PatientSetupHasAdminInitial();
}

class PatientSetupHasAdminRefreshed extends PatientSetupState {
  const PatientSetupHasAdminRefreshed();
}

class PatientSetupNoAdmin extends PatientSetupState {
  final InviteResponse inviteResponse;

  const PatientSetupNoAdmin(this.inviteResponse);

  @override
  List<Object?> get props => [inviteResponse];
}

class PatientSetupError extends PatientSetupState {
  final String message;

  const PatientSetupError(this.message);

  @override
  List<Object?> get props => [message];
}
