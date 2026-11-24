import 'dart:io';

import 'package:flutter/material.dart';

/// Shared circular profile picture widget used across auth and profile screens.
///
/// Displays [imageFile] if present, otherwise [imageUrl], or falls back to
/// [initials] / a default person icon. Tapping anywhere on the widget (including
/// the bottom-right `+` badge when [showAddBadge] is true) invokes [onTap].
class ProfilePictureWidget extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final String? initials;
  final double size;
  final bool showAddBadge;
  final bool isLoading;
  final VoidCallback? onTap;

  const ProfilePictureWidget({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.initials,
    this.size = 110,
    this.showAddBadge = false,
    this.isLoading = false,
    this.onTap,
  });

  bool get hasPhoto =>
      imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeSize = (size * 0.28).clamp(24.0, 34.0);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasPhoto
                    ? null
                    : LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: hasPhoto
                    ? theme.colorScheme.surfaceContainerHighest
                    : null,
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarContent(theme),
              ),
            ),
            if (isLoading)
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (showAddBadge && !isLoading)
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: theme.colorScheme.onPrimary,
                    size: badgeSize * 0.65,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContent(ThemeData theme) {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(theme),
      );
    }

    return _buildFallback(theme);
  }

  Widget _buildFallback(ThemeData theme) {
    final trimmedInitials = initials?.trim() ?? '';
    if (trimmedInitials.isNotEmpty && trimmedInitials != '?') {
      return Center(
        child: Text(
          trimmedInitials,
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.32,
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        Icons.person_outline_rounded,
        color: theme.colorScheme.onPrimary,
        size: size * 0.45,
      ),
    );
  }
}
