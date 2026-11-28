import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';

import '../repositories/i_tracking_repository.dart';

@injectable
class RemoveSafeZoneUseCase {
  final ITrackingRepository _repository;
  RemoveSafeZoneUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String patientId,
    required String safeZoneId,
  }) =>
      _repository.removeSafeZone(
        patientId: patientId,
        safeZoneId: safeZoneId,
      );
}
