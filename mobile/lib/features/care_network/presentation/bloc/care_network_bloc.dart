import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'care_network_event.dart';
import 'care_network_state.dart';
import '../../domain/repositories/care_network_repository.dart';

@injectable
class CareNetworkBloc extends Bloc<CareNetworkEvent, CareNetworkState> {
  final CareNetworkRepository repository;

  CareNetworkBloc(this.repository) : super(CareNetworkInitial()) {
    on<FetchNetworkUsers>(_onFetchNetworkUsers);
    on<GeneratePatientInviteLink>(_onGeneratePatientInviteLink);
    on<GenerateCaregiverInviteLink>(_onGenerateCaregiverInviteLink);
    on<ClearGeneratedLink>(_onClearGeneratedLink);
    on<RemoveUserEvent>(_onRemoveUserEvent);
  }

  Future<void> _onFetchNetworkUsers(
    FetchNetworkUsers event,
    Emitter<CareNetworkState> emit,
  ) async {
    emit(CareNetworkLoading());

    final result = await repository.getNetworkUsers();

    result.fold((failure) => emit(CareNetworkError(failure.message)), (users) {
      final patients = users.where((u) => u.role == 'patient').toList();
      final caregivers = users.where((u) => u.role == 'caregiver').toList();

      emit(CareNetworkLoaded(patients: patients, caregivers: caregivers));
    });
  }

  Future<void> _onGeneratePatientInviteLink(
    GeneratePatientInviteLink event,
    Emitter<CareNetworkState> emit,
  ) async {
    if (state is CareNetworkLoaded) {
      final currentState = state as CareNetworkLoaded;
      emit(currentState.copyWith(isGeneratingLink: true, clearLink: true));

      final result = await repository.generatePatientInviteLink();
      result.fold(
        (failure) => emit(CareNetworkError(failure.message)),
        (link) => emit(
          currentState.copyWith(isGeneratingLink: false, generatedLink: link),
        ),
      );
    }
  }

  Future<void> _onGenerateCaregiverInviteLink(
    GenerateCaregiverInviteLink event,
    Emitter<CareNetworkState> emit,
  ) async {
    if (state is CareNetworkLoaded) {
      final currentState = state as CareNetworkLoaded;
      emit(currentState.copyWith(isGeneratingLink: true, clearLink: true));

      final result = await repository.generateCaregiverInviteLink();
      result.fold(
        (failure) => emit(CareNetworkError(failure.message)),
        (link) => emit(
          currentState.copyWith(isGeneratingLink: false, generatedLink: link),
        ),
      );
    }
  }

  void _onClearGeneratedLink(
    ClearGeneratedLink event,
    Emitter<CareNetworkState> emit,
  ) {
    if (state is CareNetworkLoaded) {
      final currentState = state as CareNetworkLoaded;
      emit(currentState.copyWith(clearLink: true, isGeneratingLink: false));
    }
  }

  Future<void> _onRemoveUserEvent(
    RemoveUserEvent event,
    Emitter<CareNetworkState> emit,
  ) async {
    if (state is CareNetworkLoaded) {
      final currentState = state as CareNetworkLoaded;

      // Sahte bekleme
      await Future.delayed(const Duration(seconds: 1));

      final updatedPatients = currentState.patients
          .where((u) => u.id != event.userId)
          .toList();
      final updatedCaregivers = currentState.caregivers
          .where((u) => u.id != event.userId)
          .toList();

      emit(
        currentState.copyWith(
          patients: updatedPatients,
          caregivers: updatedCaregivers,
        ),
      );
    }
  }
}
