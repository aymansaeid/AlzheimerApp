import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/care_team_member_model.dart';

abstract class CareNetworkRemoteDataSource {
  Future<List<CareTeamMemberModel>> getCareTeam(String patientId);
  Future<String> generateInvite(String patientId);
  Future<void> removeTeamMember(String patientId, String followerId);
  Future<void> leaveTeam(String patientId);
}

@LazySingleton(as: CareNetworkRemoteDataSource)
class CareNetworkRemoteDataSourceImpl implements CareNetworkRemoteDataSource {
  final Dio dio;

  CareNetworkRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CareTeamMemberModel>> getCareTeam(String patientId) async {
    try {
      final response = await dio.get('/api/Follower/patient/$patientId/team');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => CareTeamMemberModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw ServerException(message: 'Sunucudan geçersiz bir yanıt alındı.');
    } on DioException catch (e) {
      throw ServerException(message: _parseProblemDetails(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> generateInvite(String patientId) async {
    try {
      final response = await dio.post(
        '/api/Follower/invite/generate',
        data: {'patientId': patientId, 'isPrimaryInvite': false},
      );
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final inviteCode = data['inviteCode'] ?? data['invite_code'];
        if (inviteCode != null) {
          return inviteCode.toString();
        }
      }
      throw ServerException(message: 'Sunucudan geçersiz davet kodu yanıtı alındı.');
    } on DioException catch (e) {
      throw ServerException(message: _parseProblemDetails(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> removeTeamMember(String patientId, String followerId) async {
    try {
      await dio.delete('/api/Follower/patient/$patientId/remove/$followerId');
    } on DioException catch (e) {
      throw ServerException(message: _parseProblemDetails(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> leaveTeam(String patientId) async {
    try {
      await dio.delete('/api/Follower/patient/$patientId/leave');
    } on DioException catch (e) {
      throw ServerException(message: _parseProblemDetails(e));
    } catch (e) {
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
