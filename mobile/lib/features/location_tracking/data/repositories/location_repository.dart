import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/features/location_tracking/data/datasources/location_remote_datasource.dart';
import '../../domain/repositories/location_repository.dart';
import '../models/location_log_model.dart';

@LazySingleton(as: LocationRepository)
class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendLocationLog({
    required double latitude,
    required double longitude,
    double? accuracy,
    int? batteryLevel,
    bool? isCharging,
  }) async {
    try {
      final model = LocationLogModel.fromDevice(
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
        batteryLevel: batteryLevel,
        isCharging: isCharging,
      );

      await remoteDataSource.logLocation(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
