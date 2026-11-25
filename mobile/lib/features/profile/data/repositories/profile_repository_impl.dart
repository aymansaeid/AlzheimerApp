import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/errors/exceptions.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/features/auth/data/models/refresh_token_response.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/memory_content/features/feed/domain/repositories/file_storage_repository.dart';

import '../../domain/entities/profile_update_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final FileStorageRepository _fileStorageRepository;
  final FlutterSecureStorage _secureStorage;

  ProfileRepositoryImpl(
    this._remoteDataSource,
    this._fileStorageRepository,
    this._secureStorage,
  );

  @override
  Future<Either<Failure, ProfileUpdateEntity>> updateProfile(
    ProfileUpdateEntity user,
  ) async {
    try {
      final updatedUser = await _remoteDataSource.updateProfile(user);

      // Refresh JWT token if email or fullName changed (JWT claims contain them)
      if (user.email != null || user.fullName != null) {
        final currentToken = await _secureStorage.read(key: 'jwt_token');
        if (currentToken != null && currentToken.isNotEmpty) {
          final refreshResult =
              await _remoteDataSource.refreshMyToken(currentToken);
          if (refreshResult != null) {
            await syncRefreshedSession(
              response: refreshResult,
              secureStorage: _secureStorage,
              authBloc: getIt<AuthBloc>(),
            );
          }
        }
      }

      // Keep local phone cache in sync
      if (user.phone != null) {
        if (user.phone!.isEmpty) {
          await _secureStorage.delete(key: 'user_phone');
        } else {
          await _secureStorage.write(key: 'user_phone', value: user.phone);
        }
      }

      return Right(updatedUser);
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

      await _remoteDataSource.updateProfile(
        ProfileUpdateEntity(profilePhotoUrl: downloadUrl),
      );
      await _secureStorage.write(key: 'user_avatar_url', value: downloadUrl);

      return Right(downloadUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
      await _remoteDataSource.updateProfile(
        const ProfileUpdateEntity(profilePhotoUrl: ''),
      );
      await _secureStorage.delete(key: 'user_avatar_url');
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
