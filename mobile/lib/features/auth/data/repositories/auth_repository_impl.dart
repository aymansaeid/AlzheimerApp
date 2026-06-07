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

      final userJson = data.containsKey('user')
          ? data['user'] as Map<String, dynamic>
          : data;
      final user = UserModel.fromJson(userJson);
      final token = (data['token'] ?? data['jwtToken'] ?? '') as String;

      if (token.isNotEmpty) {
        await secureStorage.write(key: 'jwt_token', value: token);
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
    String? phone,
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

      return loginResult.fold((failure) {
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
    try {
      final token = await secureStorage.read(key: 'jwt_token');
      debugPrint('CheckAuthStatus: Stored Token: ${token != null ? "FOUND (Length: ${token.length})" : "NULL"}');
      if (token == null || JwtDecoder.isExpired(token)) {
        if (token != null) {
          debugPrint('CheckAuthStatus: Token found but is EXPIRED. Deleting...');
          await secureStorage.delete(key: 'jwt_token');
        }
        return Left(ServerFailure('Oturum süresi doldu veya oturum bulunamadı.'));
      }

      final payload = JwtDecoder.decode(token);
      debugPrint('CheckAuthStatus: Decoded payload: $payload');
      final id = payload['sub'] ?? payload['nameid'] ?? payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? '';
      final email = payload['email'] ?? payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ?? '';
      final roleRaw = payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? payload['role'] ?? 'patient';
      final fullName = payload['FullName'] ?? payload['fullName'] ?? payload['unique_name'] ?? '';

      DateTime createdAt = DateTime.now();
      if (payload.containsKey('iat')) {
        final iat = payload['iat'];
        if (iat is int) {
          createdAt = DateTime.fromMillisecondsSinceEpoch(iat * 1000);
        }
      }

      String mappedRole = 'patient';
      final roleStr = roleRaw.toString().toLowerCase();
      if (roleStr == 'patient' || roleStr == '0') {
        mappedRole = 'patient';
      } else if (roleStr == 'caregiver' || roleStr == 'follower' || roleStr == '1') {
        mappedRole = 'caregiver';
      } else if (roleStr == 'admin' || roleStr == '2') {
        mappedRole = 'admin';
      } else {
        mappedRole = roleStr;
      }

      final user = UserModel(
        id: id.toString(),
        email: email.toString(),
        role: mappedRole,
        fullName: fullName.toString(),
        phone: payload['phone'] ?? payload['phoneNumber'] ?? payload['phone_number'],
        avatarUrl: payload['avatarUrl'] ?? payload['avatar_url'],
        fcmToken: payload['fcmToken'] ?? payload['fcm_token'],
        isActive: true,
        createdAt: createdAt,
      );

      return Right(user);
    } catch (e) {
      debugPrint('CheckAuthStatus: Exception during check: $e');
      try {
        await secureStorage.delete(key: 'jwt_token');
      } catch (_) {}
      return Left(ServerFailure('Oturum doğrulanamadı: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await secureStorage.delete(key: 'jwt_token');
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Çıkış yapılamadı: ${e.toString()}'));
    }
  }
}
