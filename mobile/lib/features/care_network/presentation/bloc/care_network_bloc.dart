import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'care_network_event.dart';
import 'care_network_state.dart';
import '../../domain/usecases/get_care_team_usecase.dart';
import '../../domain/usecases/generate_invite_usecase.dart';
import '../../domain/usecases/remove_team_member_usecase.dart';
import '../../domain/usecases/leave_team_usecase.dart';
import '../../../caregiver/domain/entities/followed_patient.dart';
import '../../domain/entities/care_team_member.dart';
import '../../../onboarding/domain/usecases/accept_invite_usecase.dart';
import '../../domain/usecases/transfer_admin_usecase.dart';

@injectable
class CareNetworkBloc extends Bloc<CareNetworkEvent, CareNetworkState> {
  final GetCareTeamUseCase getCareTeamUseCase;
  final GenerateInviteUseCase generateInviteUseCase;
  final RemoveTeamMemberUseCase removeTeamMemberUseCase;
  final LeaveTeamUseCase leaveTeamUseCase;
  final AcceptInviteUseCase acceptInviteUseCase;
  final TransferAdminUseCase transferAdminUseCase;

  String? _currentUserId;
  List<FollowedPatient> _patients = [];

  CareNetworkBloc({
    required this.getCareTeamUseCase,
    required this.generateInviteUseCase,
    required this.removeTeamMemberUseCase,
    required this.leaveTeamUseCase,
    required this.acceptInviteUseCase,
    required this.transferAdminUseCase,
  }) : super(CareNetworkInitial()) {
    on<FetchCareNetwork>(_onFetchCareNetwork);
    on<GenerateInviteClicked>(_onGenerateInviteClicked);
    on<RemoveMemberClicked>(_onRemoveMemberClicked);
    on<LeaveTeamClicked>(_onLeaveTeamClicked);
    on<ClearGeneratedInvite>(_onClearGeneratedInvite);
    on<AcceptInviteClicked>(_onAcceptInviteClicked);
    on<TransferAdminClicked>(_onTransferAdminClicked);
  }

  Future<void> _onFetchCareNetwork(
    FetchCareNetwork event,
    Emitter<CareNetworkState> emit,
  ) async {
    _currentUserId = event.currentUserId;
    emit(CareNetworkLoading());

    _patients = event.patients;

    if (_patients.isEmpty) {
      emit(CareNetworkEmpty());
      return;
    }

    final Map<String, List<CareTeamMember>> patientTeams = {};
    final Map<String, bool> isAdminForPatient = {};
    String? errorMessage;

    final futures = _patients.map((patient) async {
      final teamResult = await getCareTeamUseCase(patient.patientId);
      teamResult.fold(
        (failure) {
          errorMessage = failure.message;
        },
        (team) {
          patientTeams[patient.patientId] = team;

          // Check if current user is admin
          bool isCurrentUserAdmin = patient.isPrimaryAdmin;
          final currentUserId = event.currentUserId;
          for (final member in team) {
            if (member.id == currentUserId) {
              final normalizedRole = member.role.toLowerCase();
              if (normalizedRole == 'admin' ||
                  normalizedRole == 'primaryadmin' ||
                  normalizedRole == 'isprimaryadmin') {
                isCurrentUserAdmin = true;
              }
              break;
            }
          }
          isAdminForPatient[patient.patientId] = isCurrentUserAdmin;
        },
      );
    }).toList();

    await Future.wait(futures);

    if (errorMessage != null && patientTeams.isEmpty) {
      emit(_errorState(errorMessage!));
    } else {
      emit(
        CareNetworkLoaded(
          patients: _patients,
          patientTeams: patientTeams,
          isAdminForPatient: isAdminForPatient,
        ),
      );
    }
  }

  Future<void> _onGenerateInviteClicked(
    GenerateInviteClicked event,
    Emitter<CareNetworkState> emit,
  ) async {
    if (state is CareNetworkLoaded) {
      final currentState = state as CareNetworkLoaded;
      emit(currentState.copyWith(isGeneratingCode: true, clearCode: true));

      final result = await generateInviteUseCase(event.patientId);

      result.fold(
        (failure) => emit(_errorState(failure.message)),
        (code) => emit(
          currentState.copyWith(isGeneratingCode: false, generatedCode: code),
        ),
      );
    }
  }

  Future<void> _onRemoveMemberClicked(
    RemoveMemberClicked event,
    Emitter<CareNetworkState> emit,
  ) async {
    if (state is CareNetworkLoaded) {
      emit(CareNetworkLoading());

      final result = await removeTeamMemberUseCase(
        patientId: event.patientId,
        followerId: event.followerId,
      );

      await result.fold(
        (failure) async {
          emit(_errorState(failure.message));
        },
        (_) async {
          emit(const CareNetworkActionSuccess('Üye başarıyla çıkarıldı.'));
          add(FetchCareNetwork(_currentUserId ?? '', patients: _patients));
        },
      );
    }
  }

  Future<void> _onLeaveTeamClicked(
    LeaveTeamClicked event,
    Emitter<CareNetworkState> emit,
  ) async {
    emit(CareNetworkLoading());

    final result = await leaveTeamUseCase(event.patientId);

    result.fold(
      (failure) {
        emit(_errorState(failure.message));
        add(FetchCareNetwork(_currentUserId ?? '', patients: _patients));
      },
      (_) {
        emit(const CareNetworkActionSuccess('Takımdan başarıyla ayrıldınız.'));
        add(FetchCareNetwork(_currentUserId ?? '', patients: _patients));
      },
    );
  }

  void _onClearGeneratedInvite(
    ClearGeneratedInvite event,
    Emitter<CareNetworkState> emit,
  ) {
    if (state is CareNetworkLoaded) {
      final currentState = state as CareNetworkLoaded;
      emit(currentState.copyWith(clearCode: true, isGeneratingCode: false));
    }
  }

  Future<void> _onAcceptInviteClicked(
    AcceptInviteClicked event,
    Emitter<CareNetworkState> emit,
  ) async {
    emit(CareNetworkLoading());

    final result = await acceptInviteUseCase(
      event.inviteCode,
      event.relationship,
    );

    result.fold((failure) => emit(_errorState(failure.message)), (success) {
      if (success) {
        emit(CareNetworkJoinSuccess());
        add(FetchCareNetwork(_currentUserId ?? '', patients: _patients));
      } else {
        emit(_errorState('Davet kodu kabul edilemedi.'));
      }
    });
  }

  Future<void> _onTransferAdminClicked(
    TransferAdminClicked event,
    Emitter<CareNetworkState> emit,
  ) async {
    final previousState = state;
    emit(CareNetworkLoading());

    final result = await transferAdminUseCase(
      event.patientId,
      event.newAdminId,
    );

    await result.fold(
      (failure) async => emit(_errorState(failure.message)),
      (_) async {
        emit(const CareNetworkActionSuccess('Yöneticilik devredildi.'));

        if (previousState is CareNetworkLoaded) {
          final teamResult = await getCareTeamUseCase(event.patientId);
          teamResult.fold(
            (_) => add(FetchCareNetwork(_currentUserId ?? '', patients: _patients)),
            (updatedTeam) {
              final updatedTeams = Map<String, List<CareTeamMember>>.from(
                previousState.patientTeams,
              )..[event.patientId] = updatedTeam;
              final updatedAdminMap = Map<String, bool>.from(
                previousState.isAdminForPatient,
              )..[event.patientId] = false;
              final updatedPatients = previousState.patients.map((p) {
                if (p.patientId == event.patientId) {
                  return p.copyWith(isPrimaryAdmin: false);
                }
                return p;
              }).toList();

              _patients = updatedPatients;
              emit(
                CareNetworkLoaded(
                  patients: updatedPatients,
                  patientTeams: updatedTeams,
                  isAdminForPatient: updatedAdminMap,
                ),
              );
            },
          );
        } else {
          add(FetchCareNetwork(_currentUserId ?? '', patients: _patients));
        }
      },
    );
  }

  CareNetworkError _errorState(String message) {
    if (state is CareNetworkLoaded) {
      final loadedState = state as CareNetworkLoaded;
      return CareNetworkError(
        message,
        patients: loadedState.patients,
        patientTeams: loadedState.patientTeams,
        isAdminForPatient: loadedState.isAdminForPatient,
      );
    }
    return CareNetworkError(message, patients: _patients);
  }
}
