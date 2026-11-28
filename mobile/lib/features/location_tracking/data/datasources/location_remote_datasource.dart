import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';
import '../models/location_log_model.dart';

abstract class LocationRemoteDataSource {
  Future<void> logLocation(LocationLogModel locationModel);
}

@LazySingleton(as: LocationRemoteDataSource)
class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final Dio _dio;

  LocationRemoteDataSourceImpl(this._dio);

  @override
  Future<void> logLocation(LocationLogModel locationModel) async {
    try {
      final response = await _dio.post(
        '/api/Location/log',
        data: locationModel.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          message: 'Konum kaydedilemedi (HTTP ${response.statusCode}).',
        );
      }
    } on DioException catch (e) {
      final parsedMsg = _parseError(e);
      debugPrint('LocationRemoteDataSource [logLocation] DioException: $parsedMsg');
      throw ServerException(message: parsedMsg);
    } on ServerException {
      rethrow;
    } catch (e) {
      debugPrint('LocationRemoteDataSource [logLocation] Exception: $e');
      throw ServerException(message: e.toString());
    }
  }

  String _parseError(DioException e) {
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
    return e.message ?? 'Konum sunucuya gönderilemedi.';
  }
}
