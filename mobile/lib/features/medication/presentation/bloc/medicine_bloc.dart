import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/features/medication/domain/entities/medicine_log.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/add_medicine_usecase.dart';
import '../../domain/usecases/delete_medicine_usecase.dart';
import '../../domain/usecases/get_daily_logs_usecase.dart';
import '../../domain/usecases/mark_medicine_as_taken_usecase.dart';
import '../../domain/usecases/update_medicine_usecase.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../../domain/repositories/medicine_log_repository.dart';
import 'medicine_event.dart';
import 'medicine_state.dart';

@injectable
class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final GetDailyLogsUseCase getDailyLogsUseCase;
  final AddMedicineUseCase addMedicine;
  final UpdateMedicineUseCase updateMedicine;
  final DeleteMedicineUseCase deleteMedicine;
  final MarkMedicineAsTakenUseCase markMedicineAsTaken;
  final MedicineRepository medicineRepository;
  final MedicineLogRepository medicineLogRepository;

  DateTime _currentSelectedDate = DateTime.now();
  String? _currentPatientId;
  StreamSubscription? _medicinesSubscription;
  StreamSubscription? _medicineLogsSubscription;

  MedicineBloc({
    required this.getDailyLogsUseCase,
    required this.addMedicine,
    required this.updateMedicine,
    required this.deleteMedicine,
    required this.markMedicineAsTaken,
    required this.medicineRepository,
    required this.medicineLogRepository,
  }) : super(MedicineInitial()) {
    on<LoadDailyMedicinesEvent>(_onLoadDailyMedications);
    on<AddMedicineEvent>(_onAddMedicine);
    on<UpdateMedicineEvent>(_onUpdateMedicine);
    on<DeleteMedicineEvent>(_onDeleteMedicine);
    on<MarkAsTakenEvent>(_onMarkAsTaken);
    on<ResetMedications>(_onResetMedications);
    on<LoadMedicineDetailsEvent>(_onLoadMedicineDetails);

    _medicinesSubscription = medicineRepository.onMedicinesChanged.listen((_) {
      if (_currentPatientId != null) {
        add(LoadDailyMedicinesEvent(_currentPatientId!, _currentSelectedDate));
      }
    });

    _medicineLogsSubscription = medicineLogRepository.onMedicineLogsChanged
        .listen((_) {
          if (_currentPatientId != null) {
            add(
              LoadDailyMedicinesEvent(_currentPatientId!, _currentSelectedDate),
            );
          }
        });
  }

  @override
  Future<void> close() {
    _medicinesSubscription?.cancel();
    _medicineLogsSubscription?.cancel();
    return super.close();
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
      emit(
        MedicineError(
          'Hasta bilgisi henüz yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
      return;
    }

    _currentPatientId = patientId;

    final logsResult = await getDailyLogsUseCase(patientId, event.selectedDate);
    final medicinesResult = await medicineRepository.getMedicines(patientId);

    logsResult.fold(
      (failure) => emit(MedicineError(_mapFailureToMessage(failure))),
      (logs) {
        medicinesResult.fold(
          (failure) => emit(MedicineError(_mapFailureToMessage(failure))),
          (allMedicines) => emit(
            MedicineLoaded(
              medicines: logs,
              allMedicines: allMedicines,
              selectedDate: _currentSelectedDate,
              patientId: _currentPatientId,
            ),
          ),
        );
      },
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
        emit(const MedicineOperationSuccess("İlaç alındı olarak işaretlendi."));
        if (_currentPatientId != null) {
          add(
            LoadDailyMedicinesEvent(_currentPatientId!, _currentSelectedDate),
          );
        }
      },
    );
  }

  Future<void> _onLoadMedicineDetails(
    LoadMedicineDetailsEvent event,
    Emitter<MedicineState> emit,
  ) async {
    final currentState = state;
    List<MedicineLog> currentLogs = [];
    DateTime selectedDate = DateTime.now();
    String? patientId = event.patientId;

    if (currentState is MedicineLoaded) {
      currentLogs = currentState.medicines;
      selectedDate = currentState.selectedDate;
      patientId = currentState.patientId;
    }

    emit(MedicineLoading());
    final result = await medicineRepository.getMedicines(event.patientId);
    result.fold(
      (failure) => emit(MedicineError(_mapFailureToMessage(failure))),
      (medicines) {
        try {
          final match = medicines.firstWhere((m) => m.id == event.medicineId);
          emit(MedicineDetailsLoaded(match));
          emit(MedicineLoaded(
            medicines: currentLogs,
            selectedDate: selectedDate,
            patientId: patientId,
            selectedMedicineDetails: match,
          ));
        } catch (_) {
          emit(const MedicineError('İlaç bulunamadı.'));
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
