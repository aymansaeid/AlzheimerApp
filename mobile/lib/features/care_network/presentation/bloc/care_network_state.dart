import 'package:equatable/equatable.dart';
import '../../domain/entities/network_user.dart';

abstract class CareNetworkState extends Equatable {
  const CareNetworkState();

  @override
  List<Object?> get props => [];
}

class CareNetworkInitial extends CareNetworkState {}

class CareNetworkLoading extends CareNetworkState {}

class CareNetworkLoaded extends CareNetworkState {
  final List<NetworkUser> patients;
  final List<NetworkUser> caregivers;

  const CareNetworkLoaded({
    required this.patients,
    required this.caregivers,
  });

  @override
  List<Object?> get props => [patients, caregivers];
}

class CareNetworkError extends CareNetworkState {
  final String message;

  const CareNetworkError(this.message);

  @override
  List<Object?> get props => [message];
}
