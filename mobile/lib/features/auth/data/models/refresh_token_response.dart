import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../presentation/bloc/auth_event.dart';
import 'user_model.dart';

/// Parsed payload returned by `POST /api/Auth/refresh-my-token`.
class RefreshTokenResponse {
  final String? token;
  final UserModel? user;

  const RefreshTokenResponse({
    this.token,
    this.user,
  });

  factory RefreshTokenResponse.fromDynamic(dynamic data) {
    if (data is Map<String, dynamic>) {
      final rawToken = data['token'] ?? data['accessToken'] ?? data['data'];
      final token = rawToken?.toString().trim();

      UserModel? user;
      final rawUser = data['user'];
      if (rawUser is Map<String, dynamic>) {
        user = UserModel.fromJson(rawUser);
      }

      return RefreshTokenResponse(
        token: (token != null && token.isNotEmpty) ? token : null,
        user: user,
      );
    }

    if (data is String) {
      final token = data.replaceAll('"', '').trim();
      return RefreshTokenResponse(
        token: token.isNotEmpty ? token : null,
      );
    }

    return const RefreshTokenResponse();
  }
}

/// Persists refreshed JWT/user fields to secure storage and updates [AuthBloc].
Future<void> syncRefreshedSession({
  required RefreshTokenResponse response,
  required FlutterSecureStorage secureStorage,
  required AuthBloc authBloc,
}) async {
  final token = response.token;
  if (token != null && token.isNotEmpty) {
    await secureStorage.write(key: 'jwt_token', value: token);
  }

  final User? user = response.user;
  if (user != null) {
    await secureStorage.write(key: 'user_id', value: user.id);

    if (user.phone != null && user.phone!.isNotEmpty) {
      await secureStorage.write(key: 'user_phone', value: user.phone);
    } else {
      await secureStorage.delete(key: 'user_phone');
    }

    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      await secureStorage.write(key: 'user_avatar_url', value: user.avatarUrl);
    } else {
      await secureStorage.delete(key: 'user_avatar_url');
    }

    authBloc.add(AuthUserRefreshed(user));
  }
}
