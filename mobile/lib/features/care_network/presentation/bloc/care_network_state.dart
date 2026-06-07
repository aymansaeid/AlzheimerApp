import 'package:equatable/equatable.dart';
import '../../domain/entities/care_team_member.dart';
import '../../../caregiver/domain/entities/followed_patient.dart';

abstract class CareNetworkState extends Equatable {
  const CareNetworkState();

  @override
  List<Object?> get props => [];
}

class CareNetworkInitial extends CareNetworkState {}

class CareNetworkLoading extends CareNetworkState {}

class CareNetworkLoaded extends CareNetworkState {
  final List<FollowedPatient> patients;
  final Map<String, List<CareTeamMember>> patientTeams;
  final Map<String, bool> isAdminForPatient;
  final String? generatedCode;
  final bool isGeneratingCode;

  const CareNetworkLoaded({
    required this.patients,
    required this.patientTeams,
    required this.isAdminForPatient,
    this.generatedCode,
    this.isGeneratingCode = false,
  });

  CareNetworkLoaded copyWith({
    List<FollowedPatient>? patients,
    Map<String, List<CareTeamMember>>? patientTeams,
    Map<String, bool>? isAdminForPatient,
    String? generatedCode,
    bool? isGeneratingCode,
    bool clearCode = false,
  }) {
    return CareNetworkLoaded(
      patients: patients ?? this.patients,
      patientTeams: patientTeams ?? this.patientTeams,
      isAdminForPatient: isAdminForPatient ?? this.isAdminForPatient,
      generatedCode: clearCode ? null : (generatedCode ?? this.generatedCode),
      isGeneratingCode: isGeneratingCode ?? this.isGeneratingCode,
    );
  }

  @override
  List<Object?> get props => [
        patients,
        patientTeams,
        isAdminForPatient,
        generatedCode,
        isGeneratingCode,
      ];
}

class CareNetworkError extends CareNetworkState {
  final String message;

  const CareNetworkError(this.message);

  @override
  List<Object?> get props => [message];
}

class CareNetworkLeftTeamSuccess extends CareNetworkState {}

class CareNetworkJoinSuccess extends CareNetworkState {}

class CareNetworkActionSuccess extends CareNetworkState {
  final String message;

  const CareNetworkActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CareNetworkEmpty extends CareNetworkState {}

