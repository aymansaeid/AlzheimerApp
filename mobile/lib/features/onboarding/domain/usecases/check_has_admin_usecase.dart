import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/follower_repository.dart';

@lazySingleton
class CheckHasAdminUseCase {
  final FollowerRepository repository;

  CheckHasAdminUseCase(this.repository);

  Future<Either<Failure, bool>> call(String patientId) {
    return repository.checkHasAdmin(patientId);
  }
}
