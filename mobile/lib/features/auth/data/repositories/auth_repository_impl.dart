import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final result = await _remoteDataSource.login(email, password);
      
      // Save token securely on success
      await _secureStorage.write(key: 'access_token', value: result.token);
      
      return Right(result.user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(UnauthorizedFailure('Geçersiz e-posta veya şifre.'));
      }
      return const Left(ServerFailure('Sunucu ile iletişim kurulamadı.'));
    } catch (e) {
      return const Left(ServerFailure('Beklenmeyen bir hata oluştu.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _secureStorage.delete(key: 'access_token');
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Önbellek temizlenemedi.'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    return const Left(CacheFailure('Henüz implemente edilmedi.'));
  }
}
