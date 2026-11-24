import 'dart:io';
import 'package:injectable/injectable.dart';
import '../entities/memory_content.dart';
import '../repositories/file_storage_repository.dart';
import '../repositories/memory_repository.dart';

@lazySingleton
class CreateMemoryUseCase {
  final FileStorageRepository _fileStorage;
  final MemoryRepository _memoryRepository;

  CreateMemoryUseCase(this._fileStorage, this._memoryRepository);

  Future<MemoryContent> call({
    File? file,
    required String patientId,
    required MemoryContentType contentType,
    String? title,
    String? description,
    required String relationship,
    required String uploaderId,
  }) async {
    String fileUrl = '';

    // 1. Yalnızca dosya varsa (resim veya ses) Firebase Storage'a yükle
    if (file != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last; // örn: jpg, png, m4a
      final folder = contentType == MemoryContentType.voice
          ? 'memories/voice'
          : 'memories/photos';
      final fileName = '${patientId}_$timestamp.$extension';

      fileUrl = await _fileStorage.uploadFile(
        file: file,
        fileName: fileName,
        folderPath: folder,
      );
    }

    // 2. Backend tarafına kayıt isteği at
    try {
      return await _memoryRepository.createMemory(
        patientId: patientId,
        fileUrl: fileUrl,
        contentType: contentType,
        title: title,
        description: description,
        relationship: relationship,
        uploaderId: uploaderId,
      );
    } catch (e) {
      // 3. Rollback (Geri Alma): Backend kaydı başarısız olursa Firebase'e yüklenen dosyayı sil!
      if (fileUrl.isNotEmpty) {
        try {
          await _fileStorage.deleteFile(fileUrl);
        } catch (_) {}
      }
      rethrow;
    }
  }
}
