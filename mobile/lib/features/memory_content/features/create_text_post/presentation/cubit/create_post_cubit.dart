import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/features/memory_content/feed/domain/entities/post.dart';

import '../../../../../../core/services/media_service.dart';
import '../../../../../../core/services/permission_service.dart';
import '../../../../feed/domain/usecases/add_post_usecase.dart';
import 'create_post_state.dart';

@injectable
class CreatePostCubit extends Cubit<CreatePostState> {
  final PermissionService _permissionService;
  final MediaService _mediaService;
  final AddPostUseCase _addPostUseCase;

  CreatePostCubit(
    this._permissionService,
    this._mediaService,
    this._addPostUseCase,
  ) : super(const CreatePostState());

  void onTitleChanged(String title) {
    emit(state.copyWith(title: title));
  }

  void onContentChanged(String content) {
    emit(state.copyWith(content: content));
  }

  Future<void> pickImage() async {
    // Zaten seçim yapılıyorsa tıklamayı yok say
    if (state.isPickingImage) return;

    emit(state.copyWith(isPickingImage: true));

    try {
      // 1. İzin kontrolü
      final hasPermission = await _permissionService.requestGalleryPermission();
      if (!hasPermission) {
        emit(state.copyWith(permissionDenied: true, isPickingImage: false));
        return;
      }

      emit(state.copyWith(permissionDenied: false));

      // 2. Görsel seç ve kırp
      final File? croppedImage = await _mediaService.pickAndCropImage();
      if (croppedImage != null) {
        emit(
          state.copyWith(
            selectedImage: () => croppedImage,
            isPickingImage: false,
          ),
        );
      } else {
        emit(state.copyWith(isPickingImage: false));
      }
    } catch (_) {
      emit(state.copyWith(isPickingImage: false));
    }
  }

  void removeImage() {
    emit(state.copyWith(selectedImage: () => null));
  }

  Future<void> openAppSettings() async {
    await _permissionService.openSettings();
  }

  Future<void> submitPost() async {
    if (!state.isValid || state.status == CreatePostStatus.submitting) return;

    emit(state.copyWith(status: CreatePostStatus.submitting));

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: PostType.text,
      createdAt: DateTime.now(),
      title: state.title.trim().isNotEmpty ? state.title.trim() : null,
      content: state.content.trim().isNotEmpty ? state.content.trim() : null,
      imageUrl: state.selectedImage?.path,
      userId: 'user_1',
      userName: 'Ekrem',
    );

    final result = await _addPostUseCase(newPost);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CreatePostStatus.failure,
          errorMessage: () => failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: CreatePostStatus.success)),
    );
  }
}
