import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';

import '../entities/profile_user.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, ProfileUser>> call(ProfileUser user) {
    return _repository.updateProfile(user);
  }
}
