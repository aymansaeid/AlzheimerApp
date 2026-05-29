import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

@lazySingleton
class GetDashboardSummary {
  final DashboardRepository repository;

  GetDashboardSummary(this.repository);

  Future<Either<Failure, DashboardSummary>> call(String patientId) {
    return repository.getPatientDashboardSummary(patientId);
  }
}
