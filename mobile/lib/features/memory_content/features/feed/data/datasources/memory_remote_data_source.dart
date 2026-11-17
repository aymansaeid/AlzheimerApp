import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/memory_content_model.dart';

abstract class MemoryRemoteDataSource {
  Future<MemoryContentModel> createMemory(Map<String, dynamic> requestBody);
  Future<List<MemoryContentModel>> getPatientMemories(
    String patientId,
    Map<String, dynamic> queryParams,
  );
  Future<void> deleteMemory(String id);
  Future<void> updateMemory(String id, Map<String, dynamic> requestBody);
}

@LazySingleton(as: MemoryRemoteDataSource)
class MemoryRemoteDataSourceImpl implements MemoryRemoteDataSource {
  final Dio _dio;

  MemoryRemoteDataSourceImpl(this._dio);

  @override
  Future<MemoryContentModel> createMemory(
    Map<String, dynamic> requestBody,
  ) async {
    // Swagger: POST /api/MemoryContent
    try {
      final response = await _dio.post('/api/MemoryContent', data: requestBody);
      return MemoryContentModel.fromJson(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      String errorMsg = e.message ?? 'Bir hata oluştu.';
      if (data is Map) {
        if (data.containsKey('errors')) {
          errorMsg = data['errors'].toString();
        } else if (data.containsKey('message')) {
          errorMsg = data['message'].toString();
        } else if (data.containsKey('title')) {
          errorMsg = data['title'].toString();
        }
      } else if (data != null) {
        errorMsg = data.toString();
      }
      throw Exception(errorMsg);
    }
  }

  @override
  Future<List<MemoryContentModel>> getPatientMemories(
    String patientId,
    Map<String, dynamic> queryParams,
  ) async {
    // Swagger: GET /api/MemoryContent/patient/{patientId}
    final response = await _dio.get(
      '/api/MemoryContent/patient/$patientId',
      queryParameters: queryParams,
    );
    return (response.data as List)
        .map((e) => MemoryContentModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> updateMemory(String id, Map<String, dynamic> requestBody) async {
    // Swagger: PUT /api/MemoryContent/{id}
    await _dio.put('/api/MemoryContent/$id', data: requestBody);
  }

  @override
  Future<void> deleteMemory(String id) async {
    // Swagger: DELETE /api/MemoryContent/{id}
    await _dio.delete('/api/MemoryContent/$id');
  }
}
