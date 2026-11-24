import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../domain/entities/loved_one.dart';

class LovedOnesGrid extends StatelessWidget {
  final List<LovedOne> lovedOnes;
  final BoxConstraints constraints;
  final ValueChanged<String> onMemoryPersonTapped;

  const LovedOnesGrid({
    super.key,
    required this.lovedOnes,
    required this.constraints,
    required this.onMemoryPersonTapped,
  });

  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: lovedOnes.length,
      itemBuilder: (context, i) {
        final p = lovedOnes[i];
        final trimmedUrl = p.profilePhotoUrl?.trim();
        final hasPhoto = trimmedUrl != null && trimmedUrl.isNotEmpty;

        final fallback = Container(
          width: double.infinity,
          height: double.infinity,
          color: _getColor(i),
          child: Center(
            child: AvatarCircle(
              initials: _getInitials(p.fullName),
              size: 64,
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.2),
              textStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );

        return AppCard(
          padding: EdgeInsets.zero,
          onTap: () => onMemoryPersonTapped(p.fullName),
          child: Column(
            children: [
              Expanded(
                child: hasPhoto
                    ? Image.network(
                        trimmedUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return fallback;
                        },
                        errorBuilder: (context, error, stackTrace) => fallback,
                      )
                    : fallback,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        p.fullName,
                        style: theme.textTheme.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(p.relationshipType, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColor(int index) {
    final colors = [
      const Color(0xFFE1F5EE),
      const Color(0xFFE6F1FB),
      const Color(0xFFFAECE7),
      const Color(0xFFFAEEDA),
    ];
    return colors[index % colors.length];
  }
}
