import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/services/media_service.dart';
import 'package:mobile/core/services/permission_service.dart';

import '../../domain/usecases/add_profile_picture_usecase.dart';
import '../../domain/usecases/remove_profile_picture_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AddProfilePictureUseCase _addProfilePictureUseCase;
  final RemoveProfilePictureUseCase _removeProfilePictureUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final MediaService _mediaService;
  final PermissionService _permissionService;

  ProfileBloc(
    this._addProfilePictureUseCase,
    this._removeProfilePictureUseCase,
    this._updateProfileUseCase,
    this._mediaService,
    this._permissionService,
  ) : super(const ProfileState()) {
    on<ProfilePicturePickRequested>(_onPicturePickRequested);
    on<ProfilePictureRemoveRequested>(_onPictureRemoveRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfilePermissionWarningCleared>(_onPermissionWarningCleared);
  }

  Future<void> _onPicturePickRequested(
    ProfilePicturePickRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(clearError: true, clearPermissionDenied: true));

    final hasPermission = event.source == ImageSource.camera
        ? await _permissionService.requestCameraPermission()
        : await _permissionService.requestGalleryPermission();

    if (!hasPermission) {
      emit(
        state.copyWith(
          permissionDeniedType:
              event.source == ImageSource.camera ? 'camera' : 'gallery',
        ),
      );
      return;
    }

    try {
      final imageFile = await _mediaService.pickAndCropImage(
        source: event.source,
      );
      if (imageFile == null) return;

      emit(state.copyWith(isAvatarLoading: true));

      final result = await _addProfilePictureUseCase(
        imageFile: imageFile,
        userId: event.userId,
        currentAvatarUrl: event.currentAvatarUrl,
      );

      result.fold(
        (failure) => emit(
          state.copyWith(
            isAvatarLoading: false,
            errorMessage: failure.message,
          ),
        ),
        (newUrl) => emit(
          state.copyWith(
            isAvatarLoading: false,
            updatedAvatarUrl: newUrl,
            avatarRemoved: false,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isAvatarLoading: false,
          errorMessage: 'Profil fotoğrafı güncellenemedi: $e',
        ),
      );
    }
  }

  Future<void> _onPictureRemoveRequested(
    ProfilePictureRemoveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isAvatarLoading: true, clearError: true));

    final result = await _removeProfilePictureUseCase(event.currentAvatarUrl);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isAvatarLoading: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isAvatarLoading: false,
          clearUpdatedAvatarUrl: true,
          avatarRemoved: true,
        ),
      ),
    );
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        isUpdatingProfile: true,
        clearError: true,
        clearUpdatedProfile: true,
      ),
    );

    final result = await _updateProfileUseCase(event.user);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isUpdatingProfile: false,
          errorMessage: failure.message,
        ),
      ),
      (updatedUser) => emit(
        state.copyWith(
          isUpdatingProfile: false,
          updatedProfile: updatedUser,
        ),
      ),
    );
  }

  void _onPermissionWarningCleared(
    ProfilePermissionWarningCleared event,
    Emitter<ProfileState> emit,
  ) {
    emit(state.copyWith(clearPermissionDenied: true));
  }
}
