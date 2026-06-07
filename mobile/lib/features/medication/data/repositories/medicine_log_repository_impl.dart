import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/medicine_log.dart';
import '../../domain/repositories/medicine_log_repository.dart';
import '../datasources/medicine_log_remote_data_source.dart';

@LazySingleton(as: MedicineLogRepository)
class MedicineLogRepositoryImpl implements MedicineLogRepository {
  final MedicineLogRemoteDataSource remoteDataSource;

  MedicineLogRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<MedicineLog>>> getDailyLogs(
    String patientId,
    DateTime date,
  ) async {
    try {
      final logs = await remoteDataSource.getDailyLogs(patientId, date);
      return Right(logs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
