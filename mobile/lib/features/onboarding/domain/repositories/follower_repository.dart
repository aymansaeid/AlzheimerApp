import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/invite_response.dart';

abstract class FollowerRepository {
  Stream<void> get onInviteAccepted;
  Future<Either<Failure, bool>> checkHasAdmin(String patientId);
  Future<Either<Failure, InviteResponse>> generateInvite(
    String patientId,
    bool isPrimary,
  );
  Future<Either<Failure, bool>> acceptInvite(
    String inviteCode,
    String relationship,
  );
}
