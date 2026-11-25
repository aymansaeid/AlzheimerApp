import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medicine.dart';

abstract class MedicineRepository {
  Stream<void> get onMedicinesChanged;
  Future<Either<Failure, Medicine>> addMedicine(Medicine medicine);
  Future<Either<Failure, List<Medicine>>> getMedicines(String patientId);
  Future<Either<Failure, Medicine>> getMedicineById(String id);
  Future<Either<Failure, Medicine>> updateMedicine(Medicine medicine);
  Future<Either<Failure, void>> deleteMedicine(String id);
}
