import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/profile_update_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfilePicturePickRequested extends ProfileEvent {
  final ImageSource source;
  final String userId;
  final String? currentAvatarUrl;

  const ProfilePicturePickRequested({
    required this.source,
    required this.userId,
    this.currentAvatarUrl,
  });

  @override
  List<Object?> get props => [source, userId, currentAvatarUrl];
}

class ProfilePictureRemoveRequested extends ProfileEvent {
  final String currentAvatarUrl;

  const ProfilePictureRemoveRequested({required this.currentAvatarUrl});

  @override
  List<Object?> get props => [currentAvatarUrl];
}

class ProfileUpdateRequested extends ProfileEvent {
  final ProfileUpdateEntity user;

  const ProfileUpdateRequested({required this.user});

  @override
  List<Object?> get props => [user];
}

class ProfilePermissionWarningCleared extends ProfileEvent {
  const ProfilePermissionWarningCleared();
}
