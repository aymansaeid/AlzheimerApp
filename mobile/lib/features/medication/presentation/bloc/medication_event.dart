import 'package:equatable/equatable.dart';
import '../../domain/entities/medication.dart';

abstract class MedicationEvent extends Equatable {
  const MedicationEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedications extends MedicationEvent {
  final DateTime date;

  const LoadMedications(this.date);

  @override
  List<Object?> get props => [date];
}

class AddMedicationEvent extends MedicationEvent {
  final Medication medication;

  const AddMedicationEvent(this.medication);

  @override
  List<Object?> get props => [medication];
}

class UpdateMedicationEvent extends MedicationEvent {
  final Medication medication;

  const UpdateMedicationEvent(this.medication);

  @override
  List<Object?> get props => [medication];
}

class DeleteMedicationEvent extends MedicationEvent {
  final String id;

  const DeleteMedicationEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAsTakenEvent extends MedicationEvent {
  final String id;
  final DateTime date;

  const MarkAsTakenEvent({required this.id, required this.date});

  @override
  List<Object?> get props => [id, date];
}
