import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';

import '../entities/profile_update_entity.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, ProfileUpdateEntity>> call(
    ProfileUpdateEntity user,
  ) {
    return _repository.updateProfile(user);
  }
}
