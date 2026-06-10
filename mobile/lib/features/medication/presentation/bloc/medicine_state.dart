import 'package:equatable/equatable.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/entities/medicine_log.dart';

abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineLoading extends MedicineState {}

class MedicineLoaded extends MedicineState {
  final List<MedicineLog> medicines;
  final DateTime selectedDate;
  final String? patientId;

  const MedicineLoaded({
    required this.medicines,
    required this.selectedDate,
    this.patientId,
  });

  @override
  List<Object?> get props => [medicines, selectedDate, patientId];
}

class MedicineError extends MedicineState {
  final String message;

  const MedicineError(this.message);

  @override
  List<Object?> get props => [message];
}

class MedicineOperationSuccess extends MedicineState {
  final String message;

  const MedicineOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
