import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';

import '../repositories/profile_repository.dart';

@lazySingleton
class RemoveProfilePictureUseCase {
  final ProfileRepository _repository;

  RemoveProfilePictureUseCase(this._repository);

  Future<Either<Failure, void>> call(String currentAvatarUrl) {
    return _repository.removeProfilePicture(currentAvatarUrl);
  }
}
