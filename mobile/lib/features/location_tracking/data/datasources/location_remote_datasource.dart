import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:injectable/injectable.dart';
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
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      debugPrint('LocationRemoteDataSource [logLocation] Exception: $e');
      rethrow;
    }
  }
}
