import 'package:equatable/equatable.dart';

abstract class CareNetworkEvent extends Equatable {
  const CareNetworkEvent();

  @override
  List<Object?> get props => [];
}

class FetchNetworkUsers extends CareNetworkEvent {}

class GeneratePatientInviteLink extends CareNetworkEvent {}

class GenerateCaregiverInviteLink extends CareNetworkEvent {}

class ClearGeneratedLink extends CareNetworkEvent {}

class RemoveUserEvent extends CareNetworkEvent {
  final String userId;

  const RemoveUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
