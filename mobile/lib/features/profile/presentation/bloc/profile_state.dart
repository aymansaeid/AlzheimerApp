import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isAvatarLoading;
  final bool isUpdatingProfile;
  final String? updatedAvatarUrl;
  final bool avatarRemoved;
  final bool profileUpdated;
  final String? errorMessage;
  final String? permissionDeniedType;

  const ProfileState({
    this.isAvatarLoading = false,
    this.isUpdatingProfile = false,
    this.updatedAvatarUrl,
    this.avatarRemoved = false,
    this.profileUpdated = false,
    this.errorMessage,
    this.permissionDeniedType,
  });

  ProfileState copyWith({
    bool? isAvatarLoading,
    bool? isUpdatingProfile,
    String? updatedAvatarUrl,
    bool clearUpdatedAvatarUrl = false,
    bool? avatarRemoved,
    bool? profileUpdated,
    String? errorMessage,
    bool clearError = false,
    String? permissionDeniedType,
    bool clearPermissionDenied = false,
  }) {
    return ProfileState(
      isAvatarLoading: isAvatarLoading ?? this.isAvatarLoading,
      isUpdatingProfile: isUpdatingProfile ?? this.isUpdatingProfile,
      updatedAvatarUrl: clearUpdatedAvatarUrl
          ? null
          : (updatedAvatarUrl ?? this.updatedAvatarUrl),
      avatarRemoved: avatarRemoved ?? false,
      profileUpdated: profileUpdated ?? false,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      permissionDeniedType: clearPermissionDenied
          ? null
          : (permissionDeniedType ?? this.permissionDeniedType),
    );
  }

  @override
  List<Object?> get props => [
        isAvatarLoading,
        isUpdatingProfile,
        updatedAvatarUrl,
        avatarRemoved,
        profileUpdated,
        errorMessage,
        permissionDeniedType,
      ];
}
