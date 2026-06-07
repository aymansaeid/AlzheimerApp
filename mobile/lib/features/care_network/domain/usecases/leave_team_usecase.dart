import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/care_network_repository.dart';

@lazySingleton
class LeaveTeamUseCase {
  final CareNetworkRepository repository;

  LeaveTeamUseCase(this.repository);

  Future<Either<Failure, void>> call(String patientId) {
    return repository.leaveTeam(patientId);
  }
}
