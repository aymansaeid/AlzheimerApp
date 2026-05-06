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
  final String? generatedLink;
  final bool isGeneratingLink;

  const CareNetworkLoaded({
    required this.patients,
    required this.caregivers,
    this.generatedLink,
    this.isGeneratingLink = false,
  });

  CareNetworkLoaded copyWith({
    List<NetworkUser>? patients,
    List<NetworkUser>? caregivers,
    String? generatedLink,
    bool? isGeneratingLink,
    bool clearLink = false,
  }) {
    return CareNetworkLoaded(
      patients: patients ?? this.patients,
      caregivers: caregivers ?? this.caregivers,
      generatedLink: clearLink ? null : (generatedLink ?? this.generatedLink),
      isGeneratingLink: isGeneratingLink ?? this.isGeneratingLink,
    );
  }

  @override
  List<Object?> get props => [
    patients,
    caregivers,
    generatedLink,
    isGeneratingLink,
  ];
}

class CareNetworkError extends CareNetworkState {
  final String message;

  const CareNetworkError(this.message);

  @override
  List<Object?> get props => [message];
}
