import 'package:equatable/equatable.dart';
import '../../domain/entities/medication.dart';

abstract class MedicationState extends Equatable {
  const MedicationState();

  @override
  List<Object?> get props => [];
}

class MedicationInitial extends MedicationState {}

class MedicationLoading extends MedicationState {}

class MedicationLoaded extends MedicationState {
  final List<Medication> medications;
  final DateTime selectedDate;
  final String? patientId;

  const MedicationLoaded({
    required this.medications,
    required this.selectedDate,
    this.patientId,
  });

  @override
  List<Object?> get props => [medications, selectedDate, patientId];
}

class MedicationError extends MedicationState {
  final String message;

  const MedicationError(this.message);

  @override
  List<Object?> get props => [message];
}

class MedicationOperationSuccess extends MedicationState {
  final String message;

  const MedicationOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
