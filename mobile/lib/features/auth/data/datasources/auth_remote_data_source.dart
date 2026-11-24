import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';
import '../models/login_dto.dart';
import '../models/register_dto.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required int role,
    String? phone,
    String? avatarUrl,
  });

  Future<void> updateFcmToken(String fcmToken);
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
    try {
      final loginDto = LoginDto(email: email, password: password);
      final response = await dio.post(
        '/api/Auth/login',
        data: loginDto.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw ServerException(message: 'Sunucudan geçersiz bir yanıt alındı.');
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint('AuthRemoteDataSource [Login] DioException: $parsedMsg');
      debugPrint('Response: ${e.response?.statusCode} - ${e.response?.data}');
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint('AuthRemoteDataSource [Login] Generic Exception: $e\n$stack');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required int role,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final registerDto = RegisterDto(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
        avatarUrl: avatarUrl,
      );
      final response = await dio.post(
        '/api/Auth/register',
        data: registerDto.toJson(),
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw ServerException(message: 'Sunucudan geçersiz bir yanıt alındı.');
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint('AuthRemoteDataSource [Register] DioException: $parsedMsg');
      debugPrint('Response: ${e.response?.statusCode} - ${e.response?.data}');
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'AuthRemoteDataSource [Register] Generic Exception: $e\n$stack',
      );
      throw ServerException(message: e.toString());
    }
  }

  String _parseProblemDetails(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('detail') &&
          data['detail'] != null &&
          data['detail'].toString().isNotEmpty) {
        return data['detail'].toString();
      }
      if (data.containsKey('title') &&
          data['title'] != null &&
          data['title'].toString().isNotEmpty) {
        return data['title'].toString();
      }
      if (data.containsKey('errors') && data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final messages = <String>[];
        errors.forEach((key, value) {
          if (value is List) {
            messages.add(value.join(', '));
          } else if (value is String) {
            messages.add(value);
          }
        });
        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    }
    return e.message ?? 'Bilinmeyen bir sunucu hatası oluştu.';
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    await dio.post(
      '/api/Auth/update-fcm-token',
      data: {'fcmToken': fcmToken},
    );
  }
}
