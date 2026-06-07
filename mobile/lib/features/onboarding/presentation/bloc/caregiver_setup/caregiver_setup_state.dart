import 'package:equatable/equatable.dart';

abstract class CaregiverSetupState extends Equatable {
  const CaregiverSetupState();

  @override
  List<Object?> get props => [];
}

class CaregiverSetupInitial extends CaregiverSetupState {}

class CaregiverSetupLoading extends CaregiverSetupState {}

class CaregiverSetupEmpty extends CaregiverSetupState {}

class CaregiverSetupHasPatients extends CaregiverSetupState {}

class CaregiverSetupError extends CaregiverSetupState {
  final String message;

  const CaregiverSetupError(this.message);

  @override
  List<Object?> get props => [message];
}
