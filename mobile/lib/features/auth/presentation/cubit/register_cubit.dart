import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/services/media_service.dart';
import 'package:mobile/core/services/permission_service.dart';
import 'package:mobile/features/memory_content/features/feed/domain/repositories/file_storage_repository.dart';

import 'register_state.dart';

@injectable
class RegisterCubit extends Cubit<RegisterState> {
  final MediaService _mediaService;
  final PermissionService _permissionService;
  final FileStorageRepository _fileStorageRepository;

  RegisterCubit(
    this._mediaService,
    this._permissionService,
    this._fileStorageRepository,
  ) : super(const RegisterState());

  void selectRole(String role) {
    emit(state.copyWith(selectedRole: role, clearError: true));
  }

  Future<void> pickAvatar(ImageSource source) async {
    emit(state.copyWith(clearError: true, clearPermissionDenied: true));

    final hasPermission = source == ImageSource.camera
        ? await _permissionService.requestCameraPermission()
        : await _permissionService.requestGalleryPermission();

    if (!hasPermission) {
      emit(
        state.copyWith(
          permissionDeniedType:
              source == ImageSource.camera ? 'camera' : 'gallery',
        ),
      );
      return;
    }

    try {
      final file = await _mediaService.pickAndCropImage(source: source);
      if (file != null) {
        emit(state.copyWith(selectedAvatarFile: file));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Fotoğraf seçilemedi: $e'));
    }
  }

  void removeAvatar() {
    emit(state.copyWith(clearAvatarFile: true, clearError: true));
  }

  Future<String?> uploadAvatarIfSelected() async {
    final file = state.selectedAvatarFile;
    if (file == null) return null;

    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final fileName =
          'avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final url = await _fileStorageRepository.uploadFile(
        file: file,
        fileName: fileName,
        folderPath: 'profile_pictures',
      );
      emit(state.copyWith(isLoading: false));
      return url;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Profil fotoğrafı yüklenemedi: $e',
        ),
      );
      return null;
    }
  }

  void clearPermissionWarning() {
    emit(state.copyWith(clearPermissionDenied: true));
  }
}
