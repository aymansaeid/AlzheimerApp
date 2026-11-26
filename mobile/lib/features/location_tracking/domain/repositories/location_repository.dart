import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/errors/failures.dart';

abstract class LocationRepository {
  Future<Either<Failure, void>> sendLocationLog({
    required double latitude,
    required double longitude,
    double? accuracy,
    int? batteryLevel,
    bool? isCharging,
  });
}
