import 'package:flutter/material.dart';

class AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;

  const AvatarCircle({
    super.key,
    required this.initials,
    this.size = 56, // Accessible size
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
