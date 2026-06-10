import 'package:equatable/equatable.dart';
import '../../domain/entities/medicine_log.dart';
import '../../domain/entities/medicine.dart';

abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineLoading extends MedicineState {}

class MedicineLoaded extends MedicineState {
  final List<MedicineLog> medicines;
  final List<Medicine> allMedicines;
  final DateTime selectedDate;
  final String? patientId;
  final Medicine? selectedMedicineDetails;

  const MedicineLoaded({
    required this.medicines,
    this.allMedicines = const [],
    required this.selectedDate,
    this.patientId,
    this.selectedMedicineDetails,
  });

  @override
  List<Object?> get props => [medicines, allMedicines, selectedDate, patientId, selectedMedicineDetails];
}

class MedicineDetailsLoaded extends MedicineState {
  final Medicine medicine;

  const MedicineDetailsLoaded(this.medicine);

  @override
  List<Object?> get props => [medicine];
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
