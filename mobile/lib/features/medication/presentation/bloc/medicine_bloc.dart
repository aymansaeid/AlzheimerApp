import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/add_medicine_usecase.dart';
import '../../domain/usecases/delete_medicine_usecase.dart';
import '../../domain/usecases/get_daily_logs_usecase.dart';
import '../../domain/usecases/mark_medicine_as_taken_usecase.dart';
import '../../domain/usecases/update_medicine_usecase.dart';
import 'medicine_event.dart';
import 'medicine_state.dart';

@injectable
class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final GetDailyLogsUseCase getDailyLogsUseCase;
  final AddMedicineUseCase addMedicine;
  final UpdateMedicineUseCase updateMedicine;
  final DeleteMedicineUseCase deleteMedicine;
  final MarkMedicineAsTakenUseCase markMedicineAsTaken;

  DateTime _currentSelectedDate = DateTime.now();
  String? _currentPatientId;

  MedicineBloc({
    required this.getDailyLogsUseCase,
    required this.addMedicine,
    required this.updateMedicine,
    required this.deleteMedicine,
    required this.markMedicineAsTaken,
  }) : super(MedicineInitial()) {
    on<LoadDailyMedicinesEvent>(_onLoadDailyMedications);
    on<AddMedicineEvent>(_onAddMedicine);
    on<UpdateMedicineEvent>(_onUpdateMedicine);
    on<DeleteMedicineEvent>(_onDeleteMedicine);
    on<MarkAsTakenEvent>(_onMarkAsTaken);
    on<ResetMedications>(_onResetMedications);
  }

  void _onResetMedications(
    ResetMedications event,
    Emitter<MedicineState> emit,
  ) {
    _currentPatientId = null;
    emit(MedicineInitial());
  }

  Future<void> _onLoadDailyMedications(
    LoadDailyMedicinesEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(MedicineLoading());
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
        MedicineError(
          'Hasta bilgisi henüz yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
      return;
    }

    _currentPatientId = patientId;

    final result = await getDailyLogsUseCase(patientId, event.selectedDate);

    result.fold(
      (failure) => emit(MedicineError(_mapFailureToMessage(failure))),
      (logs) => emit(
        MedicineLoaded(
          medicines: logs,
          selectedDate: _currentSelectedDate,
          patientId: _currentPatientId,
        ),
      ),
    );
  }

  Future<void> _onAddMedicine(
    AddMedicineEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(MedicineLoading());

    final result = await addMedicine(event.medication);

    result.fold(
      (failure) => emit(MedicineError(_mapFailureToMessage(failure))),
      (_) {
        emit(const MedicineOperationSuccess("Medication added successfully"));
        if (_currentPatientId != null) {
          add(
            LoadDailyMedicinesEvent(_currentPatientId!, _currentSelectedDate),
          );
        } else {
          emit(MedicineInitial());
        }
      },
    );
  }

  Future<void> _onUpdateMedicine(
    UpdateMedicineEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(MedicineLoading());

    final result = await updateMedicine(event.medication);

    result.fold(
      (failure) => emit(MedicineError(_mapFailureToMessage(failure))),
      (_) {
        emit(const MedicineOperationSuccess("Medication updated successfully"));
        if (_currentPatientId != null) {
          add(
            LoadDailyMedicinesEvent(_currentPatientId!, _currentSelectedDate),
          );
        } else {
          emit(MedicineInitial());
        }
      },
    );
  }

  Future<void> _onDeleteMedicine(
    DeleteMedicineEvent event,
    Emitter<MedicineState> emit,
  ) async {
    emit(MedicineLoading());

    final result = await deleteMedicine(event.id);

    result.fold(
      (failure) => emit(MedicineError(_mapFailureToMessage(failure))),
      (_) {
        emit(const MedicineOperationSuccess("Medication deleted successfully"));
        if (_currentPatientId != null) {
          add(
            LoadDailyMedicinesEvent(_currentPatientId!, _currentSelectedDate),
          );
        } else {
          emit(MedicineInitial());
        }
      },
    );
  }

  Future<void> _onMarkAsTaken(
    MarkAsTakenEvent event,
    Emitter<MedicineState> emit,
  ) async {
    final currentState = state;
    if (currentState is MedicineLoaded) {
      // Optimistic UI update: status = 1 (Taken)
      final updatedList = currentState.medicines.map((m) {
        if (m.id == event.id) {
          return m.copyWith(status: 1, takenAt: DateTime.now());
        }
        return m;
      }).toList();
      emit(
        MedicineLoaded(
          medicines: updatedList,
          selectedDate: currentState.selectedDate,
          patientId: currentState.patientId,
        ),
      );
    }

    final result = await markMedicineAsTaken(event.id, 1);

    result.fold(
      (failure) {
        emit(MedicineError(_mapFailureToMessage(failure)));
        if (_currentPatientId != null) {
          add(
            LoadDailyMedicinesEvent(_currentPatientId!, _currentSelectedDate),
          );
        }
      },
      (_) {
        if (_currentPatientId != null) {
          add(
            LoadDailyMedicinesEvent(_currentPatientId!, _currentSelectedDate),
          );
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
