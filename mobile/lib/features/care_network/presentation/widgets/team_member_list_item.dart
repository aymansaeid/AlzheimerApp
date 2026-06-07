import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: member.role == 'Admin'
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          child: Text(
            member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : 'Ü',
            style: TextStyle(
              color: member.role == 'Admin'
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.fullName,
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (isMe)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member.role == 'Admin' ? 'Yönetici (Admin)' : 'Takipçi (Viewer)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: member.role == 'Admin'
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: member.role == 'Admin' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              'Katılım: $formattedDate',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
        trailing: member.role.toLowerCase() == 'patient'
            ? null
            : (isCurrentUserAdmin && !isMe
                ? IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: onRemovePressed,
                  )
                : const Icon(Icons.chevron_right)),
        onTap: onTap,
      ),
    );
  }
}
