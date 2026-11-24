import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/features/memory_content/features/feed/domain/repositories/file_storage_repository.dart';

import '../../domain/entities/profile_user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final FileStorageRepository _fileStorageRepository;

  ProfileRepositoryImpl(
    this._remoteDataSource,
    this._fileStorageRepository,
  );

  @override
  Future<Either<Failure, ProfileUser>> updateProfile(ProfileUser user) async {
    try {
      final updatedUser = await _remoteDataSource.updateProfile(user);
      return Right(updatedUser);
    } on UnimplementedError catch (e) {
      return Left(
        ServerFailure(
          e.message ?? 'Profil güncelleme özelliği henüz aktif değil.',
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addProfilePicture({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final ext = imageFile.path.split('.').last.toLowerCase();
      final fileName =
          'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final downloadUrl = await _fileStorageRepository.uploadFile(
        file: imageFile,
        fileName: fileName,
        folderPath: 'profile_pictures',
      );
      return Right(downloadUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeProfilePicture(
    String currentAvatarUrl,
  ) async {
    try {
      await _fileStorageRepository.deleteFile(currentAvatarUrl);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
