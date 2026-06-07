import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'care_network_event.dart';
import 'care_network_state.dart';
import '../../domain/usecases/get_care_team_usecase.dart';
import '../../domain/usecases/generate_invite_usecase.dart';
import '../../domain/usecases/remove_team_member_usecase.dart';
import '../../domain/usecases/leave_team_usecase.dart';
import '../../../caregiver/domain/usecases/get_followed_patients.dart';
import '../../domain/entities/care_team_member.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/di/injection.dart';
import '../../../onboarding/domain/usecases/accept_invite_usecase.dart';

@injectable
class CareNetworkBloc extends Bloc<CareNetworkEvent, CareNetworkState> {
  final GetFollowedPatients getFollowedPatients;
  final GetCareTeamUseCase getCareTeamUseCase;
  final GenerateInviteUseCase generateInviteUseCase;
  final RemoveTeamMemberUseCase removeTeamMemberUseCase;
  final LeaveTeamUseCase leaveTeamUseCase;
  final AcceptInviteUseCase acceptInviteUseCase;

  CareNetworkBloc({
    required this.getFollowedPatients,
    required this.getCareTeamUseCase,
    required this.generateInviteUseCase,
    required this.removeTeamMemberUseCase,
    required this.leaveTeamUseCase,
    required this.acceptInviteUseCase,
  }) : super(CareNetworkInitial()) {
    on<FetchCareNetwork>(_onFetchCareNetwork);
    on<GenerateInviteClicked>(_onGenerateInviteClicked);
    on<RemoveMemberClicked>(_onRemoveMemberClicked);
    on<LeaveTeamClicked>(_onLeaveTeamClicked);
    on<ClearGeneratedInvite>(_onClearGeneratedInvite);
    on<AcceptInviteClicked>(_onAcceptInviteClicked);
  }

  Future<void> _onFetchCareNetwork(
    FetchCareNetwork event,
    Emitter<CareNetworkState> emit,
  ) async {
    emit(CareNetworkLoading());

    final patientsResult = await getFollowedPatients();

    await patientsResult.fold(
      (failure) async {
        emit(CareNetworkError(failure.message));
      },
      (patients) async {
        if (patients.isEmpty) {
          emit(CareNetworkEmpty());
          return;
        }

        final Map<String, List<CareTeamMember>> patientTeams = {};
        final Map<String, bool> isAdminForPatient = {};
        String? errorMessage;

        final futures = patients.map((patient) async {
          final teamResult = await getCareTeamUseCase(patient.patientId);
          teamResult.fold(
            (failure) {
              errorMessage = failure.message;
            },
            (team) {
              patientTeams[patient.patientId] = team;

              // Check if current user is admin
              final authState = getIt<AuthBloc>().state;
              bool isCurrentUserAdmin = patient.isPrimaryAdmin;
              if (authState is AuthAuthenticated) {
                final currentUserId = authState.user.id;
                for (final member in team) {
                  if (member.id == currentUserId) {
                    final normalizedRole = member.role.toLowerCase();
                    if (normalizedRole == 'admin' ||
                        normalizedRole == 'primaryadmin' ||
                        normalizedRole == 'isPrimaryAdmin') {
                      isCurrentUserAdmin = true;
                    }
                    break;
                  }
                }
              }
              isAdminForPatient[patient.patientId] = isCurrentUserAdmin;
            },
          );
        }).toList();

        await Future.wait(futures);

        if (errorMessage != null && patientTeams.isEmpty) {
          emit(CareNetworkError(errorMessage!));
        } else {
          emit(
            CareNetworkLoaded(
              patients: patients,
              patientTeams: patientTeams,
              isAdminForPatient: isAdminForPatient,
            ),
          );
        }
      },
    );
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
        (failure) => emit(CareNetworkError(failure.message)),
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
          emit(CareNetworkError(failure.message));
        },
        (_) async {
          emit(const CareNetworkActionSuccess('Üye başarıyla çıkarıldı.'));
          add(FetchCareNetwork());
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
      (failure) => emit(CareNetworkError(failure.message)),
      (_) {
        emit(const CareNetworkActionSuccess('Takımdan başarıyla ayrıldınız.'));
        add(FetchCareNetwork());
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

    final result = await acceptInviteUseCase(event.inviteCode, event.relationship);

    result.fold(
      (failure) => emit(CareNetworkError(failure.message)),
      (success) {
        if (success) {
          emit(CareNetworkJoinSuccess());
        } else {
          emit(const CareNetworkError('Davet kodu kabul edilemedi.'));
        }
      },
    );
  }
}
