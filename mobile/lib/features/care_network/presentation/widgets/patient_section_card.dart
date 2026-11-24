import 'package:flutter/material.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../domain/entities/care_team_member.dart';
import '../../../caregiver/domain/entities/followed_patient.dart';
import 'team_member_list_item.dart';

class PatientSectionCard extends StatelessWidget {
  final FollowedPatient patient;
  final List<CareTeamMember> team;
  final bool isAdmin;
  final String? currentUserId;
  final VoidCallback onInvitePressed;
  final VoidCallback onLeavePressed;
  final Function(CareTeamMember) onRemoveMemberPressed;
  final Function(CareTeamMember) onMemberTapped;

  const PatientSectionCard({
    super.key,
    required this.patient,
    required this.team,
    required this.isAdmin,
    this.currentUserId,
    required this.onInvitePressed,
    required this.onLeavePressed,
    required this.onRemoveMemberPressed,
    required this.onMemberTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Header
            Row(
              children: [
                AvatarCircle(
                  initials: patient.fullName.isNotEmpty
                      ? patient.fullName[0].toUpperCase()
                      : 'H',
                  size: 64,
                  imageUrl: patient.profilePhotoUrl,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hasta',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAdmin)
                  IconButton.filledTonal(
                    onPressed: onInvitePressed,
                    icon: const Icon(Icons.person_add),
                    tooltip: 'Aile Üyesi Davet Et',
                  ),
              ],
            ),
            const Divider(height: 24),
            // Team Members List
            if (team.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Bu hastanın henüz takip ekibi bulunmuyor.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: team.length,
                itemBuilder: (context, teamIndex) {
                  final member = team[teamIndex];
                  final isMe = member.id == currentUserId;
                  return TeamMemberListItem(
                    member: member,
                    isMe: isMe,
                    isCurrentUserAdmin: isAdmin,
                    onRemovePressed: () => onRemoveMemberPressed(member),
                    onTap:
                        (member.role.toLowerCase() == 'patient' ||
                            member.id.isEmpty)
                        ? null
                        : () => onMemberTapped(member),
                  );
                },
              ),
            // Leave Button (Visible only to Viewers under each patient card, hidden for Admins)
            if (!isAdmin) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onLeavePressed,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Takımdan Ayrıl'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
