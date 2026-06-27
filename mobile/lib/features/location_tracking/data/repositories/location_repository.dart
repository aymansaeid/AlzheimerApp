import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/features/location_tracking/data/datasources/location_remote_datasource.dart';
import '../../domain/repositories/location_repository.dart';
import '../models/location_log_model.dart';

@lazySingleton
class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  // final NetworkInfo networkInfo; // Varsa internet kontrolü için eklenebilir

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendLocationLog({
    required String patientId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    try {
      final model = LocationLogModel.fromDevice(
        patientId: patientId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );

      await remoteDataSource.logLocation(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
