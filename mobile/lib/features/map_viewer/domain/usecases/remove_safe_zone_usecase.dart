import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';

import '../repositories/i_tracking_repository.dart';

@injectable
class RemoveSafeZoneUseCase {
  final ITrackingRepository _repository;
  RemoveSafeZoneUseCase(this._repository);

  Future<Either<Failure, void>> call(String patientId) =>
      _repository.removeSafeZone(patientId);
}
