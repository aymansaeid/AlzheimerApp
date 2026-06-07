import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/care_team_member.dart';
import '../repositories/care_network_repository.dart';

@lazySingleton
class GetCareTeamUseCase {
  final CareNetworkRepository repository;

  GetCareTeamUseCase(this.repository);

  Future<Either<Failure, List<CareTeamMember>>> call(String patientId) {
    return repository.getCareTeam(patientId);
  }
}
