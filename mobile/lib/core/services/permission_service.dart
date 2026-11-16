import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<bool> requestGalleryPermission();
  Future<bool> requestMicrophonePermission();
  Future<bool> openSettings();
}

@LazySingleton(as: PermissionService)
class PermissionServiceImpl implements PermissionService {
  @override
  Future<bool> requestGalleryPermission() async {
    Permission permission;

    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      // Android tarafında SDK sürüm kontrolü
      // Android 13+ (API 33+) için photos izni, altı için storage izni
      final photosStatus = await Permission.photos.status;
      if (photosStatus.isGranted || photosStatus.isLimited) {
        return true;
      }
      permission = Permission.photos;
    }

    var status = await permission.status;

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isDenied) {
      status = await permission.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }
    }

    // Android 12 ve altı için photos reddedilirse storage fallback kontrolü
    if (Platform.isAndroid && !status.isGranted) {
      var storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;
      storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }

    return status.isGranted || status.isLimited;
  }

  @override
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  @override
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
