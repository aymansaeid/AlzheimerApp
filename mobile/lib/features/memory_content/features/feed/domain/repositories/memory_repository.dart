import '../entities/memory_content.dart';

abstract class MemoryRepository {
  /// Yeni bir anı oluşturur (POST /api/MemoryContent)
  Future<MemoryContent> createMemory({
    required String patientId,
    required String fileUrl,
    required MemoryContentType contentType,
    String? title,
    String? description,
    required String relationship,
  });

  /// Hastaya ait anıları getirir (GET /api/MemoryContent/patient/{patientId})
  Future<List<MemoryContent>> getPatientMemories(
    String patientId, {
    String? uploaderId,
    String? personName,
    int? contentType,
  });

  /// Anıyı günceller (PUT /api/MemoryContent/{id})
  Future<void> updateMemory(
    String id, {
    String? title,
    String? description,
    String? relationship,
    bool? isActive,
  });

  /// Anıyı siler (DELETE /api/MemoryContent/{id})
  Future<void> deleteMemory(String id);

  // İleride profiller (PagedResponse) için de buraya metod ekleyebiliriz.
}
