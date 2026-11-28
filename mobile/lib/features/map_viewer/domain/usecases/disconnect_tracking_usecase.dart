import 'package:injectable/injectable.dart';

import '../repositories/i_tracking_repository.dart';

@injectable
class DisconnectTrackingUseCase {
  final ITrackingRepository _repository;

  DisconnectTrackingUseCase(this._repository);

  Future<void> call() => _repository.disconnectRealtime();
}
