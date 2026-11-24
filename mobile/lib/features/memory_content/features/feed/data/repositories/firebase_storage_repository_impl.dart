import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/file_storage_repository.dart';

@LazySingleton(as: FileStorageRepository)
class FirebaseStorageRepositoryImpl implements FileStorageRepository {
  final FirebaseStorage _firebaseStorage;

  FirebaseStorageRepositoryImpl(this._firebaseStorage);

  @override
  Future<String> uploadFile({
    required File file,
    required String fileName,
    required String folderPath,
  }) async {
    try {
      final ref = _firebaseStorage.ref().child('$folderPath/$fileName');

      String? mimeType;
      final ext = fileName.split('.').last.toLowerCase();
      if (ext == 'jpg' || ext == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (ext == 'png') {
        mimeType = 'image/png';
      } else if (ext == 'm4a') {
        mimeType = 'audio/m4a';
      } else if (ext == 'mp3') {
        mimeType = 'audio/mp3';
      } else if (ext == 'aac') {
        mimeType = 'audio/aac';
      }

      final metadata = mimeType != null
          ? SettableMetadata(contentType: mimeType)
          : null;

      final uploadTask = await ref.putFile(file, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Firebase yükleme hatası: ${e.message}');
    } catch (e) {
      throw Exception('Bilinmeyen bir hata oluştu: $e');
    }
  }

  @override
  Future<void> deleteFile(String fileUrl) async {
    try {
      if (fileUrl.isEmpty) return;
      final ref = _firebaseStorage.refFromURL(fileUrl);
      await ref.delete();
    } catch (_) {
      // Temizleme işlemi sessizce yutulabilir veya loglanabilir
    }
  }
}
