import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../care_network/domain/entities/network_user.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DashboardSummary>> getPatientDashboardSummary(
    String patientId,
  ) async {
    try {
      final summary = await remoteDataSource.getPatientDashboardSummary(
        patientId,
      );
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NetworkUser>>> getFollowedPatients() async {
    try {
      final patients = await remoteDataSource.getFollowedPatients();
      return Right(patients);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
