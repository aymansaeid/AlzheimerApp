import 'package:injectable/injectable.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<({UserModel user, String token})> login(String email, String password);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<({UserModel user, String token})> login(String email, String password) async {
    final response = await _dioClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    // Assuming the API returns JSON like:
    // { "user": { "id": "...", "email": "...", "name": "...", "role": "..." }, "token": "..." }
    final user = UserModel.fromJson(response.data['user'] as Map<String, dynamic>);
    final token = response.data['token'] as String;
    
    return (user: user, token: token);
  }
}
