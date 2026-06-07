import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/errors/exceptions.dart';
import '../models/medicine_log_model.dart';

abstract class MedicineLogRemoteDataSource {
  Future<List<MedicineLogModel>> getDailyLogs(String patientId, DateTime date);
}

@LazySingleton(as: MedicineLogRemoteDataSource)
class MedicineLogRemoteDataSourceImpl implements MedicineLogRemoteDataSource {
  final Dio dio;

  MedicineLogRemoteDataSourceImpl(this.dio);

  @override
  Future<List<MedicineLogModel>> getDailyLogs(
    String patientId,
    DateTime date,
  ) async {
    try {
      // Format to yyyy-MM-dd format exactly
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final response = await dio.get(
        '/api/MedicineLogs/patient/$patientId/date/$dateStr',
      );

      if (response.data is List) {
        return (response.data as List)
            .map(
              (json) => MedicineLogModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('API ERROR (${e.response?.statusCode}): ${e.response?.data}');
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        debugPrint(
          'Uyarı: İlaç bulunamadı veya hasta schedulesi boş. Boş liste dönülüyor.',
        );
        return [];
      }
      final parsedMsg = _parseProblemDetails(e);
      debugPrint(
        'MedicineLogRemoteDataSource [getDailyLogs] DioException: $parsedMsg',
      );
      throw ServerException(message: parsedMsg);
    } catch (e, stack) {
      debugPrint(
        'MedicineLogRemoteDataSource [getDailyLogs] Generic Exception: $e\n$stack',
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
