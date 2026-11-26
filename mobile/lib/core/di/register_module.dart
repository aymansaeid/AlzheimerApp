import 'package:battery_plus/battery_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_storage/firebase_storage.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  FirebaseStorage get firebaseStorage => FirebaseStorage.instance;

  @lazySingleton
  AudioPlayer get audioPlayer => AudioPlayer();

  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();

  @lazySingleton
  ImageCropper get imageCropper => ImageCropper();

  @lazySingleton
  FlutterLocalNotificationsPlugin get localNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  @lazySingleton
  Battery get battery => Battery();
}
