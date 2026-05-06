import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      log(
        'REQUEST[${options.method}] => PATH: ${options.path}',
        name: 'Network',
      );
      log('Headers: ${options.headers}', name: 'Network');
      log('Data: ${options.data}', name: 'Network');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
        name: 'Network',
      );
      log('Data: ${response.data}', name: 'Network');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
        name: 'Network',
      );
      log('Message: ${err.message}', name: 'Network');
    }
    return handler.next(err);
  }
}
