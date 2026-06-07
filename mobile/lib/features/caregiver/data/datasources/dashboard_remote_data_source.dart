import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';
import '../models/dashboard_summary_model.dart';
import '../models/followed_patient_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> getPatientDashboardSummary(String patientId);
  Future<List<FollowedPatientModel>> getFollowedPatients();
}

@LazySingleton(as: DashboardRemoteDataSource)
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl(this.dio);

  @override
  Future<DashboardSummaryModel> getPatientDashboardSummary(
    String patientId,
  ) async {
    try {
      final response = await dio.get('/api/Follower/patient/$patientId/dashboard');
      if (response.data is Map<String, dynamic>) {
        return DashboardSummaryModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(message: 'Sunucudan geçersiz bir yanıt alındı.');
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'DashboardRemoteDataSource [getPatientDashboardSummary] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'DashboardRemoteDataSource [getPatientDashboardSummary] Generic Exception: $e\n$stack',
      );
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<FollowedPatientModel>> getFollowedPatients() async {
    try {
      final response = await dio.get('/api/Follower/my-patients');
      if (response.data is List) {
        return (response.data as List)
            .map((p) => FollowedPatientModel.fromJson(p as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'DashboardRemoteDataSource [getFollowedPatients] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'DashboardRemoteDataSource [getFollowedPatients] Generic Exception: $e\n$stack',
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
