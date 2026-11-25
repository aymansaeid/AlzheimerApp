import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/entities/followed_patient.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  static const _selectedPatientIdKey = 'selected_patient_id';

  final DashboardRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  DashboardRepositoryImpl(this.remoteDataSource, this.secureStorage);

  @override
  Future<Either<Failure, DashboardSummary>> getPatientDashboardSummary(
    String patientId,
  ) async {
    try {
      final summary = await remoteDataSource.getPatientDashboardSummary(
        patientId,
      );
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FollowedPatient>>> getMyPatients() async {
    try {
      final patients = await remoteDataSource.getFollowedPatients();
      return Right(patients);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<String?> getLastSelectedPatientId() async {
    try {
      final value = await secureStorage.read(key: _selectedPatientIdKey);
      if (value == null || value.isEmpty) return null;
      return value;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveLastSelectedPatientId(String patientId) async {
    try {
      await secureStorage.write(key: _selectedPatientIdKey, value: patientId);
    } catch (_) {}
  }

  @override
  Future<void> clearLastSelectedPatientId() async {
    try {
      await secureStorage.delete(key: _selectedPatientIdKey);
    } catch (_) {}
  }
}
