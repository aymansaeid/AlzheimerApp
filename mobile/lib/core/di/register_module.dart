import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  AudioPlayer get audioPlayer => AudioPlayer();

  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();

  @lazySingleton
  ImageCropper get imageCropper => ImageCropper();
}
