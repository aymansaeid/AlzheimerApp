import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../care_network/domain/entities/network_user.dart';
import '../entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardSummary>> getPatientDashboardSummary(
    String patientId,
  );
  Future<Either<Failure, List<NetworkUser>>> getFollowedPatients();
}
