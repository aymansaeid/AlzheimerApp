import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';

class ProfileInfoCard extends StatelessWidget {
  final User user;

  const ProfileInfoCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('dd.MM.yyyy').format(user.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _ProfileInfoTile(
                icon: Icons.person_outline_rounded,
                title: 'Kullanıcı Rolü',
                subtitle:
                    user.role == 'patient' ? 'Hasta Hesabı' : 'Takipçi Hesabı',
              ),
              const Divider(height: 1, indent: 56),
              _ProfileInfoTile(
                icon: Icons.calendar_today_rounded,
                title: 'Kayıt Tarihi',
                subtitle: formattedDate,
              ),
              if (user.phone != null && user.phone!.isNotEmpty) ...[
                const Divider(height: 1, indent: 56),
                _ProfileInfoTile(
                  icon: Icons.phone_android_rounded,
                  title: 'Telefon Numarası',
                  subtitle: user.phone!,
                ),
              ],
              const Divider(height: 1, indent: 56),
              _ProfileInfoTile(
                icon: Icons.check_circle_outline_rounded,
                title: 'Hesap Durumu',
                subtitle: 'Aktif',
                subtitleColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? subtitleColor;

  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: subtitleColor ?? theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
