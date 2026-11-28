import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import '../repositories/location_repository.dart';

@lazySingleton
class LogLocationUseCase {
  final LocationRepository repository;

  LogLocationUseCase(this.repository);

  Future<Either<Failure, void>> call(LogLocationParams params) async {
    return await repository.sendLocationLog(
      latitude: params.latitude,
      longitude: params.longitude,
      accuracy: params.accuracy,
      batteryLevel: params.batteryLevel,
      isCharging: params.isCharging,
    );
  }
}

class LogLocationParams {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final int? batteryLevel;
  final bool? isCharging;

  const LogLocationParams({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.batteryLevel,
    this.isCharging,
  });
}
