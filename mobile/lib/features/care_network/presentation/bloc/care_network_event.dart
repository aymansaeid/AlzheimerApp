import 'package:equatable/equatable.dart';

abstract class CareNetworkEvent extends Equatable {
  const CareNetworkEvent();

  @override
  List<Object?> get props => [];
}

class FetchCareNetwork extends CareNetworkEvent {}

class GenerateInviteClicked extends CareNetworkEvent {
  final String patientId;

  const GenerateInviteClicked(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class RemoveMemberClicked extends CareNetworkEvent {
  final String patientId;
  final String followerId;

  const RemoveMemberClicked({required this.patientId, required this.followerId});

  @override
  List<Object?> get props => [patientId, followerId];
}

class LeaveTeamClicked extends CareNetworkEvent {
  final String patientId;

  const LeaveTeamClicked(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class ClearGeneratedInvite extends CareNetworkEvent {}

class AcceptInviteClicked extends CareNetworkEvent {
  final String inviteCode;
  final String relationship;

  const AcceptInviteClicked({required this.inviteCode, required this.relationship});

  @override
  List<Object?> get props => [inviteCode, relationship];
}
