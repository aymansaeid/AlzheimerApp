import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/network_user.dart';

abstract class CareNetworkRepository {
  Future<Either<Failure, List<NetworkUser>>> getNetworkUsers();
  Future<Either<Failure, NetworkUser>> addPatient(String email);
  Future<Either<Failure, NetworkUser>> addCaregiver(String email);
}
