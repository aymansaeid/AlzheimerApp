import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/care_team_member.dart';

abstract class CareNetworkRepository {
  Stream<void> get onNetworkChanged;
  Future<Either<Failure, List<CareTeamMember>>> getCareTeam(String patientId);
  Future<Either<Failure, String>> generateInvite(String patientId);
  Future<Either<Failure, void>> removeTeamMember(String patientId, String followerId);
  Future<Either<Failure, void>> leaveTeam(String patientId);
  Future<Either<Failure, void>> transferAdminRights(String patientId, String newAdminId);
}

