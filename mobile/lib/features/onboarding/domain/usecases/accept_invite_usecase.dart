import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/follower_repository.dart';

@lazySingleton
class AcceptInviteUseCase {
  final FollowerRepository repository;

  AcceptInviteUseCase(this.repository);

  Future<Either<Failure, bool>> call(String inviteCode, String relationship) {
    return repository.acceptInvite(inviteCode, relationship);
  }
}
