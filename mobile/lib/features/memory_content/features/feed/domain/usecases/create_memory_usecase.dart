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
    required File file,
    required String patientId,
    required MemoryContentType contentType,
    String? title,
    String? description,
    required String relationship,
    required String uploaderId,
  }) async {
    // 1. Firebase için benzersiz bir dosya adı oluşturuyoruz (Çakışmaları önlemek için)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last; // örn: jpg, mp4, m4a
    final fileName = '${patientId}_$timestamp.$extension';

    // 2. Dosyayı Firebase'e yükle ve indirme URL'ini al
    final fileUrl = await _fileStorage.uploadFile(
      file: file,
      fileName: fileName,
      folderPath: 'memories',
    );

    // 3. Firebase'den dönen URL ile backend'e kayıt isteği at
    return await _memoryRepository.createMemory(
      patientId: patientId,
      fileUrl: fileUrl,
      contentType: contentType,
      title: title,
      description: description,
      relationship: relationship,
      uploaderId: uploaderId,
    );
  }
}
