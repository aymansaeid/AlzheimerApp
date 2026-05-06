import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/avatar_circle.dart';

class PatientHomeScreen extends StatelessWidget {
  final String patientName;
  final String greeting;
  final String dateString;
  final List<Map<String, dynamic>> medications;
  final List<Map<String, dynamic>> memories;
  final VoidCallback onSosPressed;
  final ValueChanged<String> onMedicationTaken;
  final ValueChanged<String> onMemoryPersonTapped;

  const PatientHomeScreen({
    super.key,
    this.patientName = 'Ahmet Bey',
    this.greeting = 'Günaydın,',
    this.dateString = 'Pazartesi, 12 Mayıs 2026',
    this.medications = const [
      {'name': 'Donepezil 10mg', 'time': 'Sabah 08:00', 'isTaken': true},
      {'name': 'Memantin 20mg', 'time': 'Akşam 20:00', 'isTaken': false},
    ],
    this.memories = const [
      {
        'emoji': '👩',
        'name': 'Fatma',
        'relation': 'Eşi',
        'color': Color(0xFFE1F5EE),
      },
      {
        'emoji': '👦',
        'name': 'Mehmet',
        'relation': 'Oğlu',
        'color': Color(0xFFE6F1FB),
      },
      {
        'emoji': '👧',
        'name': 'Zeynep',
        'relation': 'Kızı',
        'color': Color(0xFFFAECE7),
      },
      {
        'emoji': '👨',
        'name': 'Ali',
        'relation': 'Kardeşi',
        'color': Color(0xFFFAEEDA),
      },
    ],
    required this.onSosPressed,
    required this.onMedicationTaken,
    required this.onMemoryPersonTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(theme),
                  const SizedBox(height: 20),
                  _buildSOSButton(theme),
                  const SizedBox(height: 20),
                  const SectionTitle(text: 'Bugünkü İlaçlar'),
                  ...medications.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildMedicationCard(
                        theme,
                        name: m['name'],
                        time: m['time'],
                        isTaken: m['isTaken'],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionTitle(text: 'Sevdiklerin'),
                  _buildMemoryGrid(theme, constraints),
                  const SizedBox(height: 20),
                  _buildDailyStatus(theme),
                ],
              ),
            );
          },
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
              Text(greeting, style: theme.textTheme.bodyMedium),
              Text(patientName, style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(dateString, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const AvatarCircle(initials: '👴', size: 56),
      ],
    );
  }

  Widget _buildSOSButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onSosPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white70, width: 2),
          ),
          child: const Center(
            child: Text(
              '!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        label: const Text('Acil Durum'),
      ),
    );
  }

  Widget _buildMedicationCard(
    ThemeData theme, {
    required String name,
    required String time,
    required bool isTaken,
  }) {
    return AppCard(
      color: theme.colorScheme.primaryContainer.withOpacity(0.4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('💊', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(time, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          isTaken
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Alındı',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              : ElevatedButton(
                  onPressed: () => onMedicationTaken(name),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: const Text('Aldım'),
                ),
        ],
      ),
    );
  }

  Widget _buildMemoryGrid(ThemeData theme, BoxConstraints constraints) {
    int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: memories.length,
      itemBuilder: (context, i) {
        final p = memories[i];
        return AppCard(
          padding: EdgeInsets.zero,
          onTap: () => onMemoryPersonTapped(p['name']),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: p['color'],
                  child: Center(
                    child: Text(
                      p['emoji'],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        p['name'],
                        style: theme.textTheme.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(p['relation'], style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyStatus(ThemeData theme) {
    return AppCard(
      color: theme.colorScheme.secondary.withOpacity(0.1),
      child: Row(
        children: [
          const Text('☀', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugün nasılsın?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Günlük ruh halini takipçilerinle paylaş',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.secondary),
        ],
      ),
    );
  }
}
