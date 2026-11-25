import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medicine.dart';
import '../repositories/medicine_repository.dart';

@lazySingleton
class GetMedicinesUseCase {
  final MedicineRepository repository;

  GetMedicinesUseCase(this.repository);

  Future<Either<Failure, List<Medicine>>> call(String patientId) {
    return repository.getMedicines(patientId);
  }
}
