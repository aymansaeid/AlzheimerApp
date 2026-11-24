import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/errors/failures.dart';

import '../entities/profile_update_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileUpdateEntity>> updateProfile(
    ProfileUpdateEntity user,
  );

  Future<Either<Failure, String>> addProfilePicture({
    required File imageFile,
    required String userId,
  });

  Future<Either<Failure, void>> removeProfilePicture(String currentAvatarUrl);
}
