import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/care_network_repository.dart';

@lazySingleton
class GenerateInviteUseCase {
  final CareNetworkRepository repository;

  GenerateInviteUseCase(this.repository);

  Future<Either<Failure, String>> call(String patientId) {
    return repository.generateInvite(patientId);
  }
}
