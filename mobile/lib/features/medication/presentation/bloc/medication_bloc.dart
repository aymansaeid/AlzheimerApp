import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/add_medication.dart';
import '../../domain/usecases/delete_medication.dart';
import '../../domain/usecases/get_daily_logs_usecase.dart';
import '../../domain/usecases/mark_medication_as_taken.dart';
import '../../domain/usecases/update_medication.dart';
import 'medication_event.dart';
import 'medication_state.dart';

@injectable
class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final GetDailyLogsUseCase getDailyLogsUseCase;
  final AddMedication addMedication;
  final UpdateMedication updateMedication;
  final DeleteMedication deleteMedication;
  final MarkMedicationAsTaken markMedicationAsTaken;

  DateTime _currentSelectedDate = DateTime.now();
  String? _currentPatientId;

  MedicationBloc({
    required this.getDailyLogsUseCase,
    required this.addMedication,
    required this.updateMedication,
    required this.deleteMedication,
    required this.markMedicationAsTaken,
  }) : super(MedicationInitial()) {
    on<LoadDailyMedications>(_onLoadDailyMedications);
    on<AddMedicationEvent>(_onAddMedication);
    on<UpdateMedicationEvent>(_onUpdateMedication);
    on<DeleteMedicationEvent>(_onDeleteMedication);
    on<MarkAsTakenEvent>(_onMarkAsTaken);
    on<ResetMedications>(_onResetMedications);
  }

  void _onResetMedications(
    ResetMedications event,
    Emitter<MedicationState> emit,
  ) {
    _currentPatientId = null;
    emit(MedicationInitial());
  }

  Future<void> _onLoadDailyMedications(
    LoadDailyMedications event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());
    _currentSelectedDate = event.selectedDate;

    String patientId = event.patientId;
    if (patientId.isEmpty) {
      patientId = _currentPatientId ?? '';
    }

    if (patientId.isEmpty) {
      // Fallback: If logged-in user is a patient, use their own ID
      final authState = getIt<AuthBloc>().state;
      if (authState is AuthAuthenticated && authState.user.role == 'patient') {
        patientId = authState.user.id;
      }
    }

    if (patientId.isEmpty) {
      emit(
        MedicationError(
          'Hasta bilgisi henüz yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
      return;
    }

    _currentPatientId = patientId;

    final result = await getDailyLogsUseCase(patientId, event.selectedDate);

    result.fold(
      (failure) => emit(MedicationError(_mapFailureToMessage(failure))),
      (logs) => emit(
        MedicationLoaded(
          medications: logs,
          selectedDate: _currentSelectedDate,
          patientId: _currentPatientId,
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
        if (_currentPatientId != null) {
          add(LoadDailyMedications(_currentPatientId!, _currentSelectedDate));
        } else {
          emit(MedicationInitial());
        }
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
        if (_currentPatientId != null) {
          add(LoadDailyMedications(_currentPatientId!, _currentSelectedDate));
        } else {
          emit(MedicationInitial());
        }
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
        if (_currentPatientId != null) {
          add(LoadDailyMedications(_currentPatientId!, _currentSelectedDate));
        } else {
          emit(MedicationInitial());
        }
      },
    );
  }

  Future<void> _onMarkAsTaken(
    MarkAsTakenEvent event,
    Emitter<MedicationState> emit,
  ) async {
    final currentState = state;
    if (currentState is MedicationLoaded) {
      // Optimistic UI update: status = 1 (Taken)
      final updatedList = currentState.medications.map((m) {
        if (m.id == event.id) {
          return m.copyWith(status: 1, takenAt: DateTime.now());
        }
        return m;
      }).toList();
      emit(
        MedicationLoaded(
          medications: updatedList,
          selectedDate: currentState.selectedDate,
          patientId: currentState.patientId,
        ),
      );
    }

    final result = await markMedicationAsTaken(event.id, event.date);

    result.fold(
      (failure) {
        emit(MedicationError(_mapFailureToMessage(failure)));
        if (_currentPatientId != null) {
          add(LoadDailyMedications(_currentPatientId!, _currentSelectedDate));
        }
      },
      (_) {
        if (_currentPatientId != null) {
          add(LoadDailyMedications(_currentPatientId!, _currentSelectedDate));
        }
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
