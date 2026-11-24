import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

@lazySingleton
class DioClient {
  final Dio _dio;

  DioClient(
    this._dio,
    AuthInterceptor authInterceptor,
    LoggingInterceptor loggingInterceptor,
  ) {
    _dio.options = BaseOptions(
      baseUrl: dotenv.env['BASE_URL'] ?? '',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    );

    _dio.interceptors.addAll([authInterceptor, loggingInterceptor]);
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw DioException(
        message: e.toString(),
        requestOptions: RequestOptions(
          baseUrl: dotenv.env['BASE_URL'] ?? '',
          path: path,
          method: 'GET',
        ),
      );
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw DioException(
        message: e.toString(),
        requestOptions: RequestOptions(
          baseUrl: dotenv.env['BASE_URL'] ?? '',
          path: path,
          method: 'POST',
        ),
      );
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw DioException(
        message: e.toString(),
        requestOptions: RequestOptions(
          baseUrl: dotenv.env['BASE_URL'] ?? '',
          path: path,
          method: 'PUT',
        ),
      );
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw DioException(
        message: e.toString(),
        requestOptions: RequestOptions(
          baseUrl: dotenv.env['BASE_URL'] ?? '',
          path: path,
          method: 'DELETE',
        ),
      );
    }
  }
}
