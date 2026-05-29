import 'package:equatable/equatable.dart';

abstract class CaregiverSetupEvent extends Equatable {
  const CaregiverSetupEvent();

  @override
  List<Object?> get props => [];
}

class AcceptInviteCode extends CaregiverSetupEvent {
  final String inviteCode;
  final String relationship;

  const AcceptInviteCode({
    required this.inviteCode,
    required this.relationship,
  });

  @override
  List<Object?> get props => [inviteCode, relationship];
}
