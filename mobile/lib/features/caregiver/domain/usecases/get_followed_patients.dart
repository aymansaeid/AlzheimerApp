import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/followed_patient.dart';
import '../repositories/dashboard_repository.dart';

@lazySingleton
class GetFollowedPatients {
  final DashboardRepository repository;

  GetFollowedPatients(this.repository);

  Future<Either<Failure, List<FollowedPatient>>> call() {
    return repository.getMyPatients();
  }
}
