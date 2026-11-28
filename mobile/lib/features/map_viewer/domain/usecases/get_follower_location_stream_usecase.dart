import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import '../repositories/i_tracking_repository.dart';

@injectable
class GetFollowerLocationStreamUseCase {
  final ITrackingRepository _repository;
  GetFollowerLocationStreamUseCase(this._repository);

  Stream<LatLng> call() => _repository.getFollowerLocationStream();
}