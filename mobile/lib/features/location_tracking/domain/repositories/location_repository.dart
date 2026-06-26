import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failures.dart';

// Sözleşmemiz
abstract class LocationRepository {
  Future<Either<Failure, void>> sendLocationLog({
    required String patientId,
    required double latitude,
    required double longitude,
    double? accuracy,
  });
}
