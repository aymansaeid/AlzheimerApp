import 'package:flutter/material.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/status_badge.dart';

class CaregiverDashboardScreen extends StatelessWidget {
  final String caregiverName;
  final String patientName;
  final bool isPatientSafe;
  final String lastSeen;
  final int medicationCompliance;
  final int alertsToday;
  final VoidCallback onRefresh;
  final VoidCallback onOpenMap;

  const CaregiverDashboardScreen({
    super.key,
    this.caregiverName = 'Fatma Hanım',
    this.patientName = 'Ahmet Bey',
    this.isPatientSafe = true,
    this.lastSeen = '2 dakika önce',
    this.medicationCompliance = 5,
    this.alertsToday = 0,
    required this.onRefresh,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(theme),
                    const SizedBox(height: 20),
                    _buildPatientStatusCard(theme),
                    const SizedBox(height: 16),
                    _buildStatsRow(theme, constraints),
                    const SizedBox(height: 16),
                    if (alertsToday > 0) _buildAlertBanner(theme),
                    if (alertsToday > 0) const SizedBox(height: 20),
                    const SectionTitle(text: 'Hızlı Erişim'),
                    _buildQuickActions(theme),
                    const SizedBox(height: 20),
                    SectionTitle(
                      text: 'Son Aktiviteler',
                      trailing: TextButton(
                        onPressed: () {},
                        child: const Text('Tümü'),
                      ),
                    ),
                    _buildActivityFeed(theme),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Merhaba,', style: theme.textTheme.bodyMedium),
              Text('$caregiverName 👋', style: theme.textTheme.headlineLarge),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.notifications_outlined, color: theme.colorScheme.onSurfaceVariant),
            ),
            if (alertsToday > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    alertsToday.toString(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.onError),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPatientStatusCard(ThemeData theme) {
    return AppCard(
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('👴', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    isPatientSafe ? const StatusBadge.safe() : const StatusBadge.alert(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMapMock(theme),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Flexible(child: Text(lastSeen, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onOpenMap,
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                icon: const Icon(Icons.map_rounded, size: 16),
                label: const Text('Haritayı Aç'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapMock(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant,
      ),
      child: Center(
        child: Icon(Icons.map_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            value: '$medicationCompliance/7',
            label: 'İlaç Uyumu',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            value: alertsToday.toString(),
            label: 'Bugün Uyarı',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            value: '73%',
            label: 'Rutin Uyumu',
          ),
        ),
      ],
    );
  }

  Widget _buildAlertBanner(ThemeData theme) {
    return AppCard(
      color: theme.colorScheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dün akşam ilaç alınmadı',
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.error),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      {'emoji': '🗓', 'label': 'İlaç Takvimi'},
      {'emoji': '📊', 'label': 'Haftalık Rapor'},
      {'emoji': '📍', 'label': 'Güvenli Alan'},
      {'emoji': '💝', 'label': 'İçerik Ekle'},
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Column(
              children: [
                Text(a['emoji']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text(
                  a['label']!,
                  style: theme.textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityFeed(ThemeData theme) {
    final activities = [
      {'icon': '📍', 'text': 'Konum güncellendi — Kadıköy', 'time': '5 dk önce'},
      {'icon': '💊', 'text': 'Sabah ilacı alındı — Donepezil', 'time': '2 saat önce'},
      {'icon': '⚠', 'text': 'Akşam ilacı atlandı — Memantin', 'time': 'Dün 20:15'},
    ];

    return Column(
      children: activities.map((a) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(a['icon']!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    a['text']!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(a['time']!, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
