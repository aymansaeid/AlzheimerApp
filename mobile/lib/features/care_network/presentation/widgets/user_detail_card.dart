import 'package:flutter/material.dart';
import '../../domain/entities/care_team_member.dart';

class UserDetailCard extends StatelessWidget {
  final CareTeamMember user;
  final bool isMe;

  const UserDetailCard({
    super.key,
    required this.user,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              user.avatarUrl ?? (user.role == 'Admin' ? '👩‍⚕️' : '👨'),
              style: const TextStyle(fontSize: 64),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          user.fullName,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.role == 'Admin' ? 'Yönetici (Admin)' : 'Takipçi (Viewer)',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (user.relationshipType != null && user.relationshipType!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Yakınlık Derecesi: ${user.relationshipType}",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            "Telefon: ${user.phoneNumber}",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (user.email != null && user.email!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            "E-posta: ${user.email}",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (isMe)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Bu sizin profiliniz',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
