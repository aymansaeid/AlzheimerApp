import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;
  final String? imageUrl;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const AvatarCircle({
    super.key,
    required this.initials,
    this.size = 56, // Accessible size
    this.imageUrl,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trimmedUrl = imageUrl?.trim();
    final hasImage = trimmedUrl != null && trimmedUrl.isNotEmpty;

    final fallback = Center(
      child: Text(
        initials,
        style: textStyle ??
            theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: hasImage
          ? ClipOval(
              child: Image.network(
                trimmedUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return fallback;
                },
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
            )
          : fallback,
    );
  }
}
