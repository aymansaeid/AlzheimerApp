import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../domain/entities/care_team_member.dart';

class TeamMemberListItem extends StatelessWidget {
  final CareTeamMember member;
  final bool isMe;
  final bool isCurrentUserAdmin;
  final VoidCallback? onRemovePressed;
  final VoidCallback? onTap;

  const TeamMemberListItem({
    super.key,
    required this.member,
    required this.isMe,
    required this.isCurrentUserAdmin,
    this.onRemovePressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String formattedDate = DateFormat('dd.MM.yyyy').format(member.joinedAt);

    final Widget? trailingWidget = member.role.toLowerCase() == 'patient'
        ? null
        : (isCurrentUserAdmin && !isMe
            ? IconButton(
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                onPressed: onRemovePressed,
              )
            : const Icon(Icons.chevron_right));

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              AvatarCircle(
                initials: member.fullName.isNotEmpty
                    ? member.fullName[0].toUpperCase()
                    : 'Ü',
                size: 60,
                imageUrl: member.avatarUrl,
                backgroundColor: member.role == 'Admin'
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: member.role == 'Admin'
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.fullName,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isMe)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Ben',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.role == 'Admin'
                          ? 'Yönetici (Admin)'
                          : 'Takipçi (Viewer)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: member.role == 'Admin'
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: member.role == 'Admin'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    Text(
                      'Katılım: $formattedDate',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (trailingWidget != null) ...[
                const SizedBox(width: 8),
                trailingWidget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
