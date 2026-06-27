import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import '../entities/patient_dashboard.dart';
import '../repositories/patient_repository.dart';

@lazySingleton
class GetPatientDashboardUseCase {
  final PatientRepository repository;

  GetPatientDashboardUseCase(this.repository);

  Future<Either<Failure, PatientDashboard>> call() {
    return repository.getPatientDashboard();
  }
}
