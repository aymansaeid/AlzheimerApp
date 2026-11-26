import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';

import '../models/safe_zone_model.dart';
import '../models/tracked_patient_model.dart';

abstract class TrackingRemoteDataSource {
  Future<List<TrackedPatientModel>> getLatestPatients();

  Future<SafeZoneModel> createSafeZone({
    required String patientId,
    required SafeZoneModel safeZone,
  });

  Future<void> updateSafeZone({
    required String safeZoneId,
    required SafeZoneModel safeZone,
  });

  Future<void> deleteSafeZone(String safeZoneId);

  // TODO(Backend SafeZone GET): Backend'de SafeZone GET endpoint'i hazır olduğunda yorumdan çıkarılacak.
  // Future<List<SafeZoneModel>> getPatientSafeZones(String patientId);
}

@LazySingleton(as: TrackingRemoteDataSource)
class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  final Dio _dio;

  TrackingRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TrackedPatientModel>> getLatestPatients() async {
    try {
      final response = await _dio.get('/api/Location/patients/latest');
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map(TrackedPatientModel.fromLatestJson)
            .toList();
      }
      throw ServerException(message: 'Sunucudan geçersiz hasta konum yanıtı alındı.');
    } on DioException catch (e) {
      final parsedMsg = _parseError(e);
      debugPrint('TrackingRemoteDataSource [getLatestPatients] DioException: $parsedMsg');
      throw ServerException(message: parsedMsg);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<SafeZoneModel> createSafeZone({
    required String patientId,
    required SafeZoneModel safeZone,
  }) async {
    try {
      final response = await _dio.post(
        '/api/SafeZone',
        data: safeZone.toCreateJson(patientId),
      );
      if (response.data is Map<String, dynamic>) {
        return SafeZoneModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw ServerException(message: 'Güvenli bölge oluşturma yanıtı geçersiz.');
    } on DioException catch (e) {
      final parsedMsg = _parseError(e);
      debugPrint('TrackingRemoteDataSource [createSafeZone] DioException: $parsedMsg');
      throw ServerException(message: parsedMsg);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateSafeZone({
    required String safeZoneId,
    required SafeZoneModel safeZone,
  }) async {
    try {
      await _dio.put(
        '/api/SafeZone/$safeZoneId',
        data: safeZone.toUpdateJson(),
      );
    } on DioException catch (e) {
      final parsedMsg = _parseError(e);
      debugPrint('TrackingRemoteDataSource [updateSafeZone] DioException: $parsedMsg');
      throw ServerException(message: parsedMsg);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteSafeZone(String safeZoneId) async {
    try {
      await _dio.delete('/api/SafeZone/$safeZoneId');
    } on DioException catch (e) {
      final parsedMsg = _parseError(e);
      debugPrint('TrackingRemoteDataSource [deleteSafeZone] DioException: $parsedMsg');
      throw ServerException(message: parsedMsg);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // TODO(Backend SafeZone GET): Backend'de SafeZone GET endpoint'i hazır olduğunda yorumdan çıkarılacak.
  // @override
  // Future<List<SafeZoneModel>> getPatientSafeZones(String patientId) async {
  //   try {
  //     final response = await _dio.get('/api/SafeZone/patient/$patientId');
  //     if (response.data is List) {
  //       return (response.data as List)
  //           .whereType<Map<String, dynamic>>()
  //           .map(SafeZoneModel.fromJson)
  //           .toList();
  //     }
  //     return [];
  //   } on DioException catch (e) {
  //     throw ServerException(message: _parseError(e));
  //   } catch (e) {
  //     throw ServerException(message: e.toString());
  //   }
  // }

  String _parseError(DioException e) {
    if (e.response?.statusCode == 403) {
      return 'Bu hastayı görüntüleme veya güvenli bölgesini yönetme yetkiniz yok.';
    }

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['error'] != null && data['error'].toString().isNotEmpty) {
        return data['error'].toString();
      }
      if (data['detail'] != null && data['detail'].toString().isNotEmpty) {
        return data['detail'].toString();
      }
      if (data['title'] != null && data['title'].toString().isNotEmpty) {
        return data['title'].toString();
      }
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final messages = <String>[];
        errors.forEach((_, value) {
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
