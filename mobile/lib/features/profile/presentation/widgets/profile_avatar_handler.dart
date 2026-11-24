import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/di/injection.dart';
import 'package:mobile/core/services/permission_service.dart';
import 'package:mobile/core/widgets/profile_picture_options_sheet.dart';

import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

/// Opens the native profile picture action sheet and dispatches the selected
/// event to [ProfileBloc].
Future<void> handleProfileAvatarTap(
  BuildContext context, {
  required String userId,
  required String? currentAvatarUrl,
}) async {
  final hasPhoto = currentAvatarUrl != null && currentAvatarUrl.isNotEmpty;
  final action = await showProfilePictureOptionsSheet(
    context,
    hasPhoto: hasPhoto,
  );
  if (action == null || !context.mounted) return;

  final profileBloc = context.read<ProfileBloc>();

  switch (action) {
    case ProfilePictureAction.camera:
      profileBloc.add(
        ProfilePicturePickRequested(
          source: ImageSource.camera,
          userId: userId,
          currentAvatarUrl: currentAvatarUrl,
        ),
      );
      break;
    case ProfilePictureAction.gallery:
      profileBloc.add(
        ProfilePicturePickRequested(
          source: ImageSource.gallery,
          userId: userId,
          currentAvatarUrl: currentAvatarUrl,
        ),
      );
      break;
    case ProfilePictureAction.remove:
      if (hasPhoto) {
        profileBloc.add(
          ProfilePictureRemoveRequested(currentAvatarUrl: currentAvatarUrl),
        );
      }
      break;
  }
}

/// Shows a dialog guiding the user to app settings when camera/gallery
/// permission is denied.
void showProfilePermissionDialog(BuildContext context, String type) {
  final label = type == 'camera' ? 'kamera' : 'galeri';
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('İzin Gerekli'),
      content: Text(
        'Profil fotoğrafı seçmek için $label izni vermeniz gerekiyor.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            getIt<PermissionService>().openSettings();
          },
          child: const Text('Ayarlara Git'),
        ),
      ],
    ),
  );
}
