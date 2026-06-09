import '../models/medicine_log_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';

abstract class MedicineLogRemoteDataSource {
  Future<List<MedicineLogModel>> getDailyLogs(String patientId, DateTime date);
  Future<void> updateMedicineStatus(String logId, int status, String? note);
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
      // POSTGRESQL İÇİN KUSURSUZ UTC GECE YARISI FORMATI
      final cleanDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:00Z";

      final response = await dio.get(
        '/api/MedicineLogs/patient/$patientId/date/$cleanDate',
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
      if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
        return [];
      }
      throw ServerException(message: _parseProblemDetails(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateMedicineStatus(
    String logId,
    int status,
    String? note,
  ) async {
    try {
      await dio.put(
        '/api/MedicineLogs/$logId/status',
        data: {
          'status': status,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
    } on DioException catch (e) {
      throw ServerException(message: _parseProblemDetails(e));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  String _parseProblemDetails(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data.containsKey('detail') && data['detail'] != null) {
        return data['detail'].toString();
      }
      if (data.containsKey('title') && data['title'] != null) {
        return data['title'].toString();
      }
    }
    return e.message ?? 'Bilinmeyen bir sunucu hatası oluştu.';
  }
}
