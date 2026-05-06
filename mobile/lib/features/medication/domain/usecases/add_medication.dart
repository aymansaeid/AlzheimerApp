import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

@lazySingleton
class AddMedication {
  final MedicationRepository repository;

  AddMedication(this.repository);

  Future<Either<Failure, Medication>> call(Medication medication) {
    return repository.addMedication(medication);
  }
}
