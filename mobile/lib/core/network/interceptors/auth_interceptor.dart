import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path.toLowerCase();
    final isAuthPath =
        path.contains('/api/auth/login') || path.contains('/api/auth/register');

    if (!isAuthPath) {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 Unauthorized errors handles here (e.g. trigger token refresh workflow)
    if (err.response?.statusCode == 401) {
      // TODO: Implement refresh token workflow as per rules
    }
    return handler.next(err);
  }
}
