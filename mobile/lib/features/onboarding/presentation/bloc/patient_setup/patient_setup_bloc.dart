import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/check_has_admin_usecase.dart';
import '../../../domain/usecases/generate_invite_usecase.dart';
import 'patient_setup_event.dart';
import 'patient_setup_state.dart';

@injectable
class PatientSetupBloc extends Bloc<PatientSetupEvent, PatientSetupState> {
  final CheckHasAdminUseCase _checkHasAdminUseCase;
  final GenerateInviteUseCase _generateInviteUseCase;

  PatientSetupBloc(this._checkHasAdminUseCase, this._generateInviteUseCase)
    : super(PatientSetupInitial()) {
    on<CheckAdminStatus>(_onCheckAdminStatus);
    on<GenerateInviteCode>(_onGenerateInviteCode);
    on<RefreshAdminStatus>(_onRefreshAdminStatus);
  }

  Future<void> _onCheckAdminStatus(
    CheckAdminStatus event,
    Emitter<PatientSetupState> emit,
  ) async {
    emit(PatientSetupLoading());
    final result = await _checkHasAdminUseCase(event.patientId);

    await result.fold(
      (failure) async => emit(PatientSetupError(failure.message)),
      (hasAdmin) async {
        if (hasAdmin) {
          emit(PatientSetupHasAdmin());
        } else {
          // If no admin caregiver connected yet, automatically trigger invite code generation
          add(GenerateInviteCode(event.patientId));
        }
      },
    );
  }

  Future<void> _onGenerateInviteCode(
    GenerateInviteCode event,
    Emitter<PatientSetupState> emit,
  ) async {
    emit(PatientSetupLoading());
    final result = await _generateInviteUseCase(event.patientId, true);

    result.fold(
      (failure) => emit(PatientSetupError(failure.message)),
      (inviteResponse) => emit(PatientSetupNoAdmin(inviteResponse)),
    );
  }

  Future<void> _onRefreshAdminStatus(
    RefreshAdminStatus event,
    Emitter<PatientSetupState> emit,
  ) async {
    // Keep a reference to the inviteResponse if we were already in PatientSetupNoAdmin
    final currentState = state;
    dynamic savedInvite;
    if (currentState is PatientSetupNoAdmin) {
      savedInvite = currentState.inviteResponse;
    }

    emit(PatientSetupLoading());
    final result = await _checkHasAdminUseCase(event.patientId);

    result.fold((failure) => emit(PatientSetupError(failure.message)), (
      hasAdmin,
    ) {
      if (hasAdmin) {
        emit(PatientSetupHasAdmin());
      } else {
        // If still no admin connected, re-emit the PatientSetupNoAdmin state
        if (savedInvite != null) {
          emit(PatientSetupNoAdmin(savedInvite));
        } else {
          add(GenerateInviteCode(event.patientId));
        }
      }
    });
  }
}
