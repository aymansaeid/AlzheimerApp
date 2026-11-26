import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';

import '../entities/safe_zone_entity.dart';
import '../repositories/i_tracking_repository.dart';

@injectable
class SetSafeZoneUseCase {
  final ITrackingRepository _repository;
  SetSafeZoneUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String patientId,
    required SafeZoneEntity safeZone,
  }) {
    return _repository.setSafeZone(patientId: patientId, safeZone: safeZone);
  }
}
