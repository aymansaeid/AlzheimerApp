import 'package:equatable/equatable.dart';

abstract class CaregiverSetupEvent extends Equatable {
  const CaregiverSetupEvent();

  @override
  List<Object?> get props => [];
}

class CheckFollowedPatients extends CaregiverSetupEvent {}

class AcceptInvite extends CaregiverSetupEvent {
  final String code;
  final String relationship;

  const AcceptInvite({
    required this.code,
    required this.relationship,
  });

  @override
  List<Object?> get props => [code, relationship];
}
