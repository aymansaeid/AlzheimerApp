import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.secureStorage);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final data = await remoteDataSource.login(
        email: email,
        password: password,
      );

      final userJson = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userJson);
      final token = (data['token']) as String;

      if (token.isNotEmpty) {
        // Store the token and user ID in secure storage
        try {
          await secureStorage.write(key: 'jwt_token', value: token);
          await secureStorage.write(key: 'user_id', value: user.id);
        } catch (e) {
          debugPrint('Login: Exception while writing to secure storage: $e');
        }
      }

      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String fullName,
    String phone,
    int role,
  ) async {
    try {
      final data = await remoteDataSource.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );

      // Automatically log in the user using the credentials they just signed up with
      // to obtain the actual JWT token and real user profile
      final loginResult = await login(email, password);

      return await loginResult.fold((failure) {
        // If auto-login fails, fall back to parsing local inputs to prevent registration crash
        final userJson = Map<String, dynamic>.from(data);
        userJson['role'] = role;
        userJson['fullName'] = fullName;
        userJson['email'] = email;
        userJson['id'] = data['userId'] ?? data['id'] ?? '';

        final user = UserModel.fromJson(userJson);
        return Right(user);
      }, (user) => Right(user));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> checkAuthStatus() async {
    String? token;

    // 1. Read the token from secure storage
    try {
      token = await secureStorage.read(key: 'jwt_token');
      debugPrint(
        'CheckAuthStatus: Stored Token: ${token != null ? "FOUND (Length: ${token.length})" : "NULL"}',
      );
    } catch (e) {
      debugPrint('CheckAuthStatus: Exception while reading secure storage: $e');
      return Left(CacheFailure('Yerel Depolama Hatası: ${e.toString()}'));
    }

    // If there is no token, return a AuthFailure indicating that the user is not authenticated
    if (token == null || token.isEmpty) {
      debugPrint('CheckAuthStatus: No token found in secure storage.');
      return Left(AuthFailure('Oturum bulunamadı.'));
    }

    // 2. Token exists, check if it is expired
    try {
      if (JwtDecoder.isExpired(token)) {
        debugPrint('CheckAuthStatus: Token is expired. Deleting...');
        await _safeDeleteToken();
        return Left(AuthFailure('Oturum süresi doldu.'));
      }
    } catch (e) {
      debugPrint('CheckAuthStatus: Exception during expiry check: $e');
      await _safeDeleteToken();
      return Left(AuthFailure('Geçersiz token formatı.'));
    }

    // 3. Payload decoding and mapping
    try {
      const roleClaimKey =
          'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

      final payload = JwtDecoder.decode(token);

      final user = UserModel(
        id: payload['sub'] ?? '',
        email: payload['email'] ?? '',
        fullName: payload['FullName'] ?? '',
        role: (payload[roleClaimKey] ?? 'Patient').toString().toLowerCase(),
        isActive: true,
        createdAt: DateTime.now(),
      );

      return Right(user);
    } catch (e) {
      debugPrint(
        'CheckAuthStatus: Exception during token payload decoding: $e',
      );
      await _safeDeleteToken();
      return Left(AuthFailure('Oturum verisi çözümlenemedi.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _safeDeleteToken();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Çıkış yapılamadı: ${e.toString()}'));
    }
  }

  Future<void> _safeDeleteToken() async {
    try {
      await secureStorage.delete(key: 'jwt_token');
    } catch (e) {
      debugPrint('Error deleting token: $e');
    }
  }
}
