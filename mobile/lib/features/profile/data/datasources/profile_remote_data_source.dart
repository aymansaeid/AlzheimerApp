import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';

import '../../domain/entities/profile_update_entity.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileUpdateEntity> updateProfile(ProfileUpdateEntity user);
  Future<String?> refreshMyToken(String currentToken);
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<ProfileUpdateEntity> updateProfile(ProfileUpdateEntity user) async {
    try {
      final body = <String, dynamic>{
        if (user.fullName != null) 'fullName': user.fullName,
        if (user.phone != null) 'phone': user.phone,
        if (user.email != null) 'email': user.email,
        if (user.currentPassword != null)
          'currentPassword': user.currentPassword,
        if (user.newPassword != null) 'newPassword': user.newPassword,
        if (user.profilePhotoUrl != null)
          'profilePhotoUrl': user.profilePhotoUrl,
      };

      final response = await dio.put('/api/Users/me', data: body);

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return ProfileUpdateEntity(
          fullName: data['fullName']?.toString() ?? user.fullName,
          email: data['email']?.toString() ?? user.email,
          phone: (data['phone'] ?? data['phoneNumber'])?.toString() ??
              user.phone,
          profilePhotoUrl:
              (data['profilePhotoUrl'] ?? data['avatarUrl'])?.toString() ??
                  user.profilePhotoUrl,
        );
      }

      return user;
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint('ProfileRemoteDataSource [updateProfile] DioException: $parsedMsg');
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint('ProfileRemoteDataSource [updateProfile] Exception: $e\n$stack');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String?> refreshMyToken(String currentToken) async {
    try {
      final response = await dio.post(
        '/api/Auth/refresh-my-token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $currentToken',
            'Accept': '*/*',
          },
        ),
        data: '',
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          return (data['token'] ?? data['accessToken'] ?? data['data'])
              ?.toString();
        } else if (response.data is String) {
          return (response.data as String).replaceAll('"', '').trim();
        }
      }
      return null;
    } catch (e) {
      debugPrint('ProfileRemoteDataSource [refreshMyToken] Error: $e');
      return null;
    }
  }

  String _parseProblemDetails(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['detail'] != null && data['detail'].toString().isNotEmpty) {
        return data['detail'].toString();
      }
      if (data['title'] != null && data['title'].toString().isNotEmpty) {
        return data['title'].toString();
      }
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
      if (data['errors'] is Map) {
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
    return e.message ?? 'Profil güncellenirken bir sunucu hatası oluştu.';
  }
}
