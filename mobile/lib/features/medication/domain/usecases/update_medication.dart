import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

@lazySingleton
class UpdateMedication {
  final MedicationRepository repository;

  UpdateMedication(this.repository);

  Future<Either<Failure, Medication>> call(Medication medication) {
    return repository.updateMedication(medication);
  }
}
