import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/features/caregiver/domain/usecases/get_followed_patients.dart';
import '../../../domain/usecases/accept_invite_usecase.dart';
import 'caregiver_setup_event.dart';
import 'caregiver_setup_state.dart';

@injectable
class CaregiverSetupBloc
    extends Bloc<CaregiverSetupEvent, CaregiverSetupState> {
  final AcceptInviteUseCase _acceptInviteUseCase;
  final GetFollowedPatients _getFollowedPatients;

  CaregiverSetupBloc(this._acceptInviteUseCase, this._getFollowedPatients)
    : super(CaregiverSetupInitial()) {
    on<CheckFollowedPatients>(_onCheckFollowedPatients);
    on<AcceptInvite>(_onAcceptInvite);
  }

  Future<void> _onCheckFollowedPatients(
    CheckFollowedPatients event,
    Emitter<CaregiverSetupState> emit,
  ) async {
    emit(CaregiverSetupLoading());
    final result = await _getFollowedPatients();

    result.fold(
      (failure) => emit(CaregiverSetupError(failure.message)),
      (patients) {
        if (patients.isEmpty) {
          emit(CaregiverSetupEmpty());
        } else {
          emit(CaregiverSetupHasPatients());
        }
      },
    );
  }

  Future<void> _onAcceptInvite(
    AcceptInvite event,
    Emitter<CaregiverSetupState> emit,
  ) async {
    emit(CaregiverSetupLoading());
    final result = await _acceptInviteUseCase(
      event.code,
      event.relationship,
    );

    result.fold(
      (failure) => emit(CaregiverSetupError(failure.message)),
      (_) => emit(CaregiverSetupHasPatients()),
    );
  }
}
