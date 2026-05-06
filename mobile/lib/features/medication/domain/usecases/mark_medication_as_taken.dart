import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/medication_repository.dart';

@lazySingleton
class MarkMedicationAsTaken {
  final MedicationRepository repository;

  MarkMedicationAsTaken(this.repository);

  Future<Either<Failure, void>> call(String id, DateTime date) {
    return repository.markAsTaken(id, date);
  }
}
