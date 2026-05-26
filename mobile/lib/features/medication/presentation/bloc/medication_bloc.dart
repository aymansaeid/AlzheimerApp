import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';
import 'package:mobile/features/caregiver/presentation/bloc/dashboard_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/add_medication.dart';
import '../../domain/usecases/delete_medication.dart';
import '../../domain/usecases/get_medications_by_date.dart';
import '../../domain/usecases/mark_medication_as_taken.dart';
import '../../domain/usecases/update_medication.dart';
import 'medication_event.dart';
import 'medication_state.dart';

@injectable
class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final GetMedicationsByDate getMedicationsByDate;
  final AddMedication addMedication;
  final UpdateMedication updateMedication;
  final DeleteMedication deleteMedication;
  final MarkMedicationAsTaken markMedicationAsTaken;

  DateTime _currentSelectedDate = DateTime.now();

  MedicationBloc({
    required this.getMedicationsByDate,
    required this.addMedication,
    required this.updateMedication,
    required this.deleteMedication,
    required this.markMedicationAsTaken,
  }) : super(MedicationInitial()) {
    on<LoadMedications>(_onLoadMedications);
    on<AddMedicationEvent>(_onAddMedication);
    on<UpdateMedicationEvent>(_onUpdateMedication);
    on<DeleteMedicationEvent>(_onDeleteMedication);
    on<MarkAsTakenEvent>(_onMarkAsTaken);
  }

  String? _currentPatientId;

  Future<void> _onLoadMedications(
    LoadMedications event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());
    _currentSelectedDate = event.date;

    String patientId = event.patientId ?? _currentPatientId ?? '';

    if (patientId.isEmpty) {
      // Fallback 1: If logged-in user is a patient, use their own ID
      final authState = getIt<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.role == 'patient') {
        patientId = authState.user.id;
      }
    }

    if (patientId.isEmpty) {
      // Cannot resolve patient — emit error and exit
      emit(MedicationError(
        'Hasta bilgisi henüz yüklenemedi. Lütfen tekrar deneyin.',
      ));
      return;
    }

    _currentPatientId = patientId;

    final result = await getMedicationsByDate(patientId, event.date);

    result.fold(
      (failure) => emit(MedicationError(_mapFailureToMessage(failure))),
      (medications) => emit(
        MedicationLoaded(
          medications: medications,
          selectedDate: _currentSelectedDate,
        ),
      ),
    );
  }

  Future<void> _onAddMedication(
    AddMedicationEvent event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());

    final result = await addMedication(event.medication);

    result.fold(
      (failure) => emit(MedicationError(_mapFailureToMessage(failure))),
      (_) {
        emit(const MedicationOperationSuccess("Medication added successfully"));
        add(LoadMedications(_currentSelectedDate)); // Reload list
      },
    );
  }

  Future<void> _onUpdateMedication(
    UpdateMedicationEvent event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());

    final result = await updateMedication(event.medication);

    result.fold(
      (failure) => emit(MedicationError(_mapFailureToMessage(failure))),
      (_) {
        emit(
          const MedicationOperationSuccess("Medication updated successfully"),
        );
        add(LoadMedications(_currentSelectedDate)); // Reload list
      },
    );
  }

  Future<void> _onDeleteMedication(
    DeleteMedicationEvent event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());

    final result = await deleteMedication(event.id);

    result.fold(
      (failure) => emit(MedicationError(_mapFailureToMessage(failure))),
      (_) {
        emit(
          const MedicationOperationSuccess("Medication deleted successfully"),
        );
        add(LoadMedications(_currentSelectedDate)); // Reload list
      },
    );
  }

  Future<void> _onMarkAsTaken(
    MarkAsTakenEvent event,
    Emitter<MedicationState> emit,
  ) async {
    final currentState = state;
    if (currentState is MedicationLoaded) {
      // Optimistic UI update
      final updatedList = currentState.medications.map((m) {
        if (m.id == event.id) {
          return m.copyWith(isTaken: true);
        }
        return m;
      }).toList();
      emit(
        MedicationLoaded(
          medications: updatedList,
          selectedDate: currentState.selectedDate,
        ),
      );
    }

    final result = await markMedicationAsTaken(event.id, event.date);

    result.fold(
      (failure) {
        emit(MedicationError(_mapFailureToMessage(failure)));
        add(
          LoadMedications(_currentSelectedDate),
        ); // Rollback optimistic update
      },
      (_) {
        // Optimistic update already happened, reload list in background to align maps
        add(LoadMedications(_currentSelectedDate));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Unexpected error occurred';
  }
}
