import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../care_network/domain/entities/network_user.dart';
import '../repositories/dashboard_repository.dart';

@lazySingleton
class GetFollowedPatients {
  final DashboardRepository repository;

  GetFollowedPatients(this.repository);

  Future<Either<Failure, List<NetworkUser>>> call() {
    return repository.getFollowedPatients();
  }
}
