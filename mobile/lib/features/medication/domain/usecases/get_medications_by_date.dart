import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medication.dart';
import '../repositories/medication_repository.dart';

@lazySingleton
class GetMedicationsByDate {
  final MedicationRepository repository;

  GetMedicationsByDate(this.repository);

  Future<Either<Failure, List<Medication>>> call(
    String patientId,
    DateTime date,
  ) {
    return repository.getMedicationsByDate(patientId, date);
  }
}
