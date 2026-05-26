import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/invite_response.dart';
import '../repositories/follower_repository.dart';

@lazySingleton
class GenerateInviteUseCase {
  final FollowerRepository repository;

  GenerateInviteUseCase(this.repository);

  Future<Either<Failure, InviteResponse>> call(
    String patientId,
    bool isPrimary,
  ) {
    return repository.generateInvite(patientId, isPrimary);
  }
}
