import 'dart:io';

abstract class FileStorageRepository {
  /// Verilen dosyayı sunucuya (ör. Firebase Storage) yükler ve indirme (download) URL'ini döndürür.
  Future<String> uploadFile({
    required File file,
    required String fileName,
    required String folderPath,
  });

  /// Yüklenen dosyayı sunucudan (ör. Firebase Storage) siler.
  Future<void> deleteFile(String fileUrl);
}
