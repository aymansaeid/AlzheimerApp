import 'package:injectable/injectable.dart';
import '../../domain/entities/memory_content.dart';
import '../../domain/repositories/memory_repository.dart';
import '../datasources/memory_remote_data_source.dart';
import '../models/memory_content_model.dart';

@LazySingleton(as: MemoryRepository)
class MemoryRepositoryImpl implements MemoryRepository {
  final MemoryRemoteDataSource _remoteDataSource;

  MemoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<MemoryContent> createMemory({
    required String patientId,
    required String fileUrl,
    required MemoryContentType contentType,
    String? title,
    String? description,
    required String relationship,
  }) async {
    // 1. Backend'in beklediği JSON request'i oluştur
    final requestBody = MemoryContentModel.toJsonRequest(
      patientId: patientId,
      fileUrl: fileUrl,
      title: title,
      description: description,
      relationship: relationship,
      contentType: contentType.index, // 0: Photo, 1: Voice
    );

    // 2. Data source'a gönder
    return await _remoteDataSource.createMemory(requestBody);
  }

  @override
  Future<List<MemoryContent>> getPatientMemories(
    String patientId, {
    String? uploaderId,
    String? personName,
    int? contentType,
  }) async {
    final queryParams = <String, dynamic>{};
    if (uploaderId != null) queryParams['uploaderId'] = uploaderId;
    if (personName != null) queryParams['personName'] = personName;
    if (contentType != null) queryParams['contentType'] = contentType;

    return await _remoteDataSource.getPatientMemories(patientId, queryParams);
  }

  @override
  Future<void> updateMemory(
    String id, {
    String? title,
    String? description,
    String? relationship,
    bool? isActive,
  }) async {
    // Sadece null olmayan (güncellenmek istenen) değerleri JSON'a ekliyoruz
    final requestBody = <String, dynamic>{};

    if (title != null) requestBody['title'] = title;
    if (description != null) requestBody['description'] = description;
    if (relationship != null) requestBody['relationship'] = relationship;
    if (isActive != null) requestBody['isActive'] = isActive;

    await _remoteDataSource.updateMemory(id, requestBody);
  }

  @override
  Future<void> deleteMemory(String id) async {
    await _remoteDataSource.deleteMemory(id);
  }
}
