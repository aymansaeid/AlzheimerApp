import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:mobile/core/errors/failures.dart';

import '../entities/profile_user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileUser>> updateProfile(ProfileUser user);

  Future<Either<Failure, String>> addProfilePicture({
    required File imageFile,
    required String userId,
  });

  Future<Either<Failure, void>> removeProfilePicture(String currentAvatarUrl);
}
