import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import '../repositories/location_repository.dart';

@lazySingleton
class LogLocationUseCase {
  final LocationRepository repository;

  LogLocationUseCase(this.repository);

  // 'call' metodu sayesinde useCase() şeklinde doğrudan tetiklenebilir
  Future<Either<Failure, void>> call(LogLocationParams params) async {
    return await repository.sendLocationLog(
      patientId: params.patientId,
      latitude: params.latitude,
      longitude: params.longitude,
      accuracy: params.accuracy,
    );
  }
}

// UseCase parametrelerini gruplamak için yardımcı sınıf
class LogLocationParams {
  final String patientId;
  final double latitude;
  final double longitude;
  final double? accuracy;

  const LogLocationParams({
    required this.patientId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });
}
