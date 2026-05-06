import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medication.dart';

abstract class MedicationRepository {
  Future<Either<Failure, List<Medication>>> getMedicationsByDate(
    String patientId,
    DateTime date,
  );
  Future<Either<Failure, Medication>> addMedication(Medication medication);
  Future<Either<Failure, Medication>> updateMedication(Medication medication);
  Future<Either<Failure, void>> deleteMedication(String id);
  Future<Either<Failure, void>> markAsTaken(String id, DateTime date);
}
