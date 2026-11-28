import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';

import '../entities/patient_entity.dart';
import '../repositories/i_tracking_repository.dart';

@injectable
class LoadTrackedPatientsUseCase {
  final ITrackingRepository _repository;

  LoadTrackedPatientsUseCase(this._repository);

  Future<Either<Failure, List<PatientEntity>>> call() =>
      _repository.loadInitialPatientsAndConnectHub();
}
