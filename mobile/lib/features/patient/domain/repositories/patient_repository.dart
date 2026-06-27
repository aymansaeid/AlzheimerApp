import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failures.dart';
import '../entities/patient_dashboard.dart';

abstract class PatientRepository {
  Future<Either<Failure, PatientDashboard>> getPatientDashboard();
}
