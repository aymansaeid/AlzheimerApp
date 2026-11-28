import 'package:injectable/injectable.dart';

import '../entities/patient_entity.dart';
import '../repositories/i_tracking_repository.dart';

@injectable
class WatchTrackedPatientsUseCase {
  final ITrackingRepository _repository;
  WatchTrackedPatientsUseCase(this._repository);

  Stream<List<PatientEntity>> call() => _repository.watchPatients();
}
