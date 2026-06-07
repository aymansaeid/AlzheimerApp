import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_summary.dart';
import '../entities/followed_patient.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardSummary>> getPatientDashboardSummary(
    String patientId,
  );
  Future<Either<Failure, List<FollowedPatient>>> getMyPatients();
}
