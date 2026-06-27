import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';

class PatientMedicineCard extends StatelessWidget {
  final String name;
  final String time;
  final bool isTaken;
  final ValueChanged<String> onMedicineTaken;

  const PatientMedicineCard({
    super.key,
    required this.name,
    required this.time,
    required this.isTaken,
    required this.onMedicineTaken,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
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
                  onPressed: () => onMedicineTaken(name),
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
}
