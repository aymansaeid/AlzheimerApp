import 'dart:io';

import 'package:equatable/equatable.dart';

enum CreatePostStatus { initial, submitting, success, failure }

class CreatePostState extends Equatable {
  final String title;
  final String content;
  final File? selectedImage;
  final CreatePostStatus status;
  final bool permissionDenied;
  final bool isPickingImage;
  final String? errorMessage;

  const CreatePostState({
    this.title = '',
    this.content = '',
    this.selectedImage,
    this.status = CreatePostStatus.initial,
    this.permissionDenied = false,
    this.errorMessage,
    this.isPickingImage = false,
  });

  // Gönderi en az bir başlık veya içerik metni içeriyorsa paylaşılabilir
  bool get isValid => title.trim().isNotEmpty || content.trim().isNotEmpty;

  CreatePostState copyWith({
    String? title,
    String? content,
    File? Function()? selectedImage,
    CreatePostStatus? status,
    bool? permissionDenied,
    bool? isPickingImage,
    String? Function()? errorMessage,
  }) {
    return CreatePostState(
      title: title ?? this.title,
      content: content ?? this.content,
      selectedImage: selectedImage != null
          ? selectedImage()
          : this.selectedImage,
      status: status ?? this.status,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      isPickingImage: isPickingImage ?? this.isPickingImage,
    );
  }

  @override
  List<Object?> get props => [
    title,
    content,
    selectedImage,
    status,
    permissionDenied,
    errorMessage,
    isPickingImage,
  ];
}
