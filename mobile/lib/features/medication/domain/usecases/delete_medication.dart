import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/medication_repository.dart';

@lazySingleton
class DeleteMedication {
  final MedicationRepository repository;

  DeleteMedication(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteMedication(id);
  }
}
