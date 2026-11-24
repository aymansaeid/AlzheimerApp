import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ProfilePictureAction {
  camera,
  gallery,
  remove,
}

/// Shows a platform-native bottom modal sheet for profile picture actions.
///
/// When [hasPhoto] is false, shows Camera and Gallery options.
/// When [hasPhoto] is true, also shows a Remove option.
Future<ProfilePictureAction?> showProfilePictureOptionsSheet(
  BuildContext context, {
  required bool hasPhoto,
}) {
  if (Platform.isIOS) {
    return showCupertinoModalPopup<ProfilePictureAction>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Profil Fotoğrafı'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(ProfilePictureAction.camera),
            child: const Text('Fotoğraf Çek'),
          ),
          CupertinoActionSheetAction(
            onPressed: () =>
                Navigator.of(ctx).pop(ProfilePictureAction.gallery),
            child: const Text('Galeriden Seç'),
          ),
          if (hasPhoto)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () =>
                  Navigator.of(ctx).pop(ProfilePictureAction.remove),
              child: const Text('Fotoğrafı Kaldır'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('İptal'),
        ),
      ),
    );
  }

  final theme = Theme.of(context);
  return showModalBottomSheet<ProfilePictureAction>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Profil Fotoğrafı',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(
              Icons.camera_alt_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Fotoğraf Çek'),
            onTap: () => Navigator.of(ctx).pop(ProfilePictureAction.camera),
          ),
          ListTile(
            leading: Icon(
              Icons.photo_library_outlined,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Galeriden Seç'),
            onTap: () => Navigator.of(ctx).pop(ProfilePictureAction.gallery),
          ),
          if (hasPhoto)
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Fotoğrafı Kaldır',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () => Navigator.of(ctx).pop(ProfilePictureAction.remove),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
