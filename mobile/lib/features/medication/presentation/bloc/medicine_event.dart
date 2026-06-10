import 'package:equatable/equatable.dart';
import '../../domain/entities/medicine.dart';

abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailyMedicinesEvent extends MedicineEvent {
  final String patientId;
  final DateTime selectedDate;
  final bool loadMedicinesList;

  const LoadDailyMedicinesEvent(
    this.patientId,
    this.selectedDate, {
    this.loadMedicinesList = false,
  });

  @override
  List<Object?> get props => [patientId, selectedDate, loadMedicinesList];
}

class AddMedicineEvent extends MedicineEvent {
  final Medicine medication;

  const AddMedicineEvent(this.medication);

  @override
  List<Object?> get props => [medication];
}

class UpdateMedicineEvent extends MedicineEvent {
  final Medicine medication;

  const UpdateMedicineEvent(this.medication);

  @override
  List<Object?> get props => [medication];
}

class DeleteMedicineEvent extends MedicineEvent {
  final String id;

  const DeleteMedicineEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAsTakenEvent extends MedicineEvent {
  final String id;
  final DateTime date;

  const MarkAsTakenEvent({required this.id, required this.date});

  @override
  List<Object?> get props => [id, date];
}

class ResetMedications extends MedicineEvent {}

class LoadMedicineDetailsEvent extends MedicineEvent {
  final String patientId;
  final String medicineId;

  const LoadMedicineDetailsEvent({required this.patientId, required this.medicineId});

  @override
  List<Object?> get props => [patientId, medicineId];
}

class LoadAllMedicinesEvent extends MedicineEvent {
  final String patientId;

  const LoadAllMedicinesEvent(this.patientId);

  @override
  List<Object?> get props => [patientId];
}
