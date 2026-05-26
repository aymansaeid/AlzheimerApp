import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
}
