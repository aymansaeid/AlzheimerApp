import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

abstract class MediaService {
  Future<File?> pickAndCropImage();
}

@LazySingleton(as: MediaService)
class MediaServiceImpl implements MediaService {
  final ImagePicker _picker;
  final ImageCropper _cropper;

  MediaServiceImpl(this._picker, this._cropper);

  @override
  Future<File?> pickAndCropImage() async {
    // 1. Galeriden görsel seçimi
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return null;

    // 2. Seçilen görseli hemen kırpma penceresine yönlendirme
    final CroppedFile? croppedFile = await _cropper.cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Fotoğrafı Kırp',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Fotoğrafı Kırp',
          aspectRatioLockEnabled: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }

    return null;
  }
}
