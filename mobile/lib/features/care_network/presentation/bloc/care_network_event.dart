import 'package:equatable/equatable.dart';

abstract class CareNetworkEvent extends Equatable {
  const CareNetworkEvent();

  @override
  List<Object?> get props => [];
}

class FetchNetworkUsers extends CareNetworkEvent {}

class AddPatient extends CareNetworkEvent {
  final String email;

  const AddPatient(this.email);

  @override
  List<Object?> get props => [email];
}

class AddCaregiver extends CareNetworkEvent {
  final String email;

  const AddCaregiver(this.email);

  @override
  List<Object?> get props => [email];
}
