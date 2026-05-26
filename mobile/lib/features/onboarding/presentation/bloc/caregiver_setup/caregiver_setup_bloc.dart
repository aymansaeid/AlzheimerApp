import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/accept_invite_usecase.dart';
import 'caregiver_setup_event.dart';
import 'caregiver_setup_state.dart';

@injectable
class CaregiverSetupBloc
    extends Bloc<CaregiverSetupEvent, CaregiverSetupState> {
  final AcceptInviteUseCase _acceptInviteUseCase;

  CaregiverSetupBloc(this._acceptInviteUseCase)
    : super(CaregiverSetupInitial()) {
    on<AcceptInviteCode>(_onAcceptInviteCode);
  }

  Future<void> _onAcceptInviteCode(
    AcceptInviteCode event,
    Emitter<CaregiverSetupState> emit,
  ) async {
    emit(CaregiverSetupLoading());
    final result = await _acceptInviteUseCase(
      event.inviteCode,
      event.relationship,
    );

    result.fold(
      (failure) => emit(CaregiverSetupError(failure.message)),
      (_) => emit(CaregiverSetupSuccess()),
    );
  }
}
