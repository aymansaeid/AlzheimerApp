import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/care_network_repository.dart';

@lazySingleton
class RemoveTeamMemberUseCase {
  final CareNetworkRepository repository;

  RemoveTeamMemberUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String patientId,
    required String followerId,
  }) {
    return repository.removeTeamMember(patientId, followerId);
  }
}
