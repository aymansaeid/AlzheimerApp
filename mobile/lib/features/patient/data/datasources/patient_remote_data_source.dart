import '../models/patient_dashboard_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';

abstract class PatientRemoteDataSource {
  Future<PatientDashboardModel> getPatientDashboard();
}

@LazySingleton(as: PatientRemoteDataSource)
class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final Dio dio;

  PatientRemoteDataSourceImpl(this.dio);

  @override
  Future<PatientDashboardModel> getPatientDashboard() async {
    try {
      final response = await dio.get('/api/Patient/Dashboard');
      if (response.data is Map<String, dynamic>) {
        return PatientDashboardModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(message: 'Sunucudan geçersiz bir yanıt alındı.');
    } on DioException catch (e) {
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'PatientRemoteDataSource [getPatientDashboard] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'PatientRemoteDataSource [getPatientDashboard] Generic Exception: $e\n$stack',
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

