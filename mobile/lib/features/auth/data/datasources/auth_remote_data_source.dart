import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // try {
    //   final response = await dio.post('/api/auth/login', data: {
    //     'email': email,
    //     'password': password,
    //   });
    //   return response.data;
    // } catch (e) {
    //   throw ServerException();
    // }

    // Backend'i simüle etmek için 2 saniye bekle
    await Future.delayed(const Duration(seconds: 2));

    final mockUserModel = UserModel(
      id: 'mock_id_123',
      email: email,
      role: 'patient',
      fullName: 'Ahmet Bey',
      isActive: true,
      createdAt: DateTime.now(),
    );

    return {'user': mockUserModel.toJson(), 'token': 'mock_jwt_token_123'};
  }

  @override
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    // try {
    //   final response = await dio.post('/api/auth/register', data: {
    //     'full_name': fullName,
    //     'email': email,
    //     'password': password,
    //     'role': role,
    //   });
    //   return response.data;
    // } catch (e) {
    //   throw ServerException();
    // }

    // Backend'i simüle etmek için 2 saniye bekle
    await Future.delayed(const Duration(seconds: 2));

    final mockUserModel = UserModel(
      id: 'mock_id_999',
      email: email,
      role: role,
      fullName: fullName,
      isActive: true,
      createdAt: DateTime.now(),
    );

    return {'user': mockUserModel.toJson(), 'token': 'mock_jwt_token_123'};
  }
}
