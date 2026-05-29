import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/invite_response_model.dart';

abstract class FollowerRemoteDataSource {
  Future<bool> checkHasAdmin(String patientId);
  Future<InviteResponseModel> generateInvite(String patientId, bool isPrimary);
  Future<bool> acceptInvite(String inviteCode, String relationship);
}

@LazySingleton(as: FollowerRemoteDataSource)
class FollowerRemoteDataSourceImpl implements FollowerRemoteDataSource {
  final Dio dio;

  FollowerRemoteDataSourceImpl(this.dio);

  @override
  Future<bool> checkHasAdmin(String patientId) async {
    try {
      final response = await dio.get(
        '/api/Follower/patient/$patientId/has-admin',
      );
      if (response.data is bool) {
        return response.data as bool;
      }
      if (response.data is Map) {
        final map = response.data as Map;
        return (map['hasAdmin'] ?? map['has_admin'] ?? false) == true;
      }
      return false;
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'FollowerRemoteDataSource [CheckHasAdmin] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'FollowerRemoteDataSource [CheckHasAdmin] Generic Exception: $e\n$stack',
      );
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<InviteResponseModel> generateInvite(
    String patientId,
    bool isPrimary,
  ) async {
    try {
      final response = await dio.post(
        '/api/Follower/invite/generate',
        data: {'patientId': patientId, 'isPrimaryInvite': isPrimary},
      );
      if (response.data is Map<String, dynamic>) {
        return InviteResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException(message: 'Sunucudan geçersiz bir yanıt alındı.');
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'FollowerRemoteDataSource [GenerateInvite] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'FollowerRemoteDataSource [GenerateInvite] Generic Exception: $e\n$stack',
      );
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> acceptInvite(String inviteCode, String relationship) async {
    try {
      final response = await dio.post(
        '/api/Follower/invite/accept',
        data: {'inviteCode': inviteCode, 'relationship': relationship},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'FollowerRemoteDataSource [AcceptInvite] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'FollowerRemoteDataSource [AcceptInvite] Generic Exception: $e\n$stack',
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
}
