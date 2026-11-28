import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/features/auth/data/models/refresh_token_response.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_event.dart';

import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../di/injection.dart';

@injectable
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  // Eşzamanlı 401 isteklerinde tek refresh çağrısı yapmak için kilit
  Future<String?>? _refreshTokenFuture;

  AuthInterceptor(this._secureStorage);

  static const String _accessTokenKey = 'jwt_token';
  static const String _refreshPath = '/api/Auth/refresh-my-token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path.toLowerCase();
    final isAuthPath =
        path.contains('/api/auth/login') ||
        path.contains('/api/auth/register') ||
        path.contains(_refreshPath.toLowerCase());

    // Refresh isteği ve login/register dışındaki isteklere token ekle
    if (!isAuthPath) {
      final token = await _secureStorage.read(key: _accessTokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path.toLowerCase();
    final isRefreshRequest = path.contains(_refreshPath.toLowerCase());

    // 1. KRİTİK KURAL: 401 alan istek refresh isteğinin kendisi ise döngüyü kır
    if (isRefreshRequest) {
      _refreshTokenFuture = null;
      await _handleLogout();
      return handler.reject(err);
    }

    // Normal bir istek 401 aldıysa refresh akışını başlat
    if (err.response?.statusCode == 401) {
      try {
        _refreshTokenFuture ??= _performRefreshToken();
        final newToken = await _refreshTokenFuture;
        _refreshTokenFuture = null;

        if (newToken != null && newToken.isNotEmpty) {
          // Başarısız olan isteğin header'ını yeni token ile güncelle
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          // Aynı Dio ile isteği yeniden yürüt (retry)
          final dio = _resolveDio();
          final response = await dio.fetch(options);
          return handler.resolve(response);
        } else {
          await _handleLogout();
          return handler.reject(err);
        }
      } catch (e) {
        _refreshTokenFuture = null;
        await _handleLogout();
        return handler.reject(err);
      }
    }

    return handler.next(err);
  }

  Dio _resolveDio() => getIt.isRegistered<Dio>() ? getIt<Dio>() : bgGetIt<Dio>();

  AuthBloc? _resolveAuthBloc() =>
      getIt.isRegistered<AuthBloc>() ? getIt<AuthBloc>() : null;

  Future<String?> _performRefreshToken() async {
    final currentToken = await _secureStorage.read(key: _accessTokenKey);
    if (currentToken == null || currentToken.isEmpty) {
      throw Exception('No token found');
    }

    // Aktif isolate'teki mevcut Dio'yu çağırıyoruz
    final dio = _resolveDio();

    final response = await dio.post(
      _refreshPath,
      options: Options(
        headers: {
          'Authorization': 'Bearer $currentToken',
          'Accept': '*/*',
        },
      ),
      data: '',
    );

    if (response.statusCode == 200 && response.data != null) {
      final parsed = RefreshTokenResponse.fromDynamic(response.data);
      if (parsed.token != null && parsed.token!.isNotEmpty) {
        await syncRefreshedSession(
          response: parsed,
          secureStorage: _secureStorage,
          authBloc: _resolveAuthBloc(),
        );
        return parsed.token;
      }
    }

    return null;
  }

  Future<void> _handleLogout() async {
    await _secureStorage.deleteAll();
    _resolveAuthBloc()?.add(AuthLogoutRequested());
  }
}
