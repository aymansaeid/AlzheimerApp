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
      // Örnek path: memories/1698765432_photo.jpg
      final ref = _firebaseStorage.ref().child('$folderPath/$fileName');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Firebase yükleme hatası: ${e.message}');
    } catch (e) {
      throw Exception('Bilinmeyen bir hata oluştu: $e');
    }
  }
}
