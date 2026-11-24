import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';

import '../repositories/profile_repository.dart';

/// Uploads a new profile picture (or replaces an existing one).
///
/// Checks whether [currentAvatarUrl] exists first; if so, deletes the previous
/// file from Firebase Storage before uploading the new image.
@lazySingleton
class AddProfilePictureUseCase {
  final ProfileRepository _repository;

  AddProfilePictureUseCase(this._repository);

  Future<Either<Failure, String>> call({
    required File imageFile,
    required String userId,
    String? currentAvatarUrl,
  }) async {
    if (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty) {
      await _repository.removeProfilePicture(currentAvatarUrl);
    }

    return _repository.addProfilePicture(
      imageFile: imageFile,
      userId: userId,
    );
  }
}
