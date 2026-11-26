import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../medication/domain/entities/medicine.dart';

class MedicineSummary extends StatelessWidget {
  final List<Medicine> medicines;

  const MedicineSummary({super.key, required this.medicines});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (medicines.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bugün için planlanmış ilaç bulunmuyor.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final med = medicines[index];
        final formattedTimes = med.scheduleTimes
            .map((t) => t.length >= 5 ? t.substring(0, 5) : t)
            .join(', ');
        final hasInstructions =
            med.instructions != null && med.instructions!.trim().isNotEmpty;
        final subtitle = hasInstructions
            ? '${med.dosage} • ${med.instructions!.trim()}'
            : med.dosage;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              context.pushNamed(
                'caregiver_medication_detail',
                pathParameters: {'id': med.id},
                queryParameters: {
                  'patientId': med.patientId,
                  'date': DateTime.now().toIso8601String(),
                },
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formattedTimes,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            med.isActive
                                ? Icons.check_circle_rounded
                                : Icons.pause_circle_rounded,
                            color: med.isActive ? Colors.green : Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            med.isActive ? 'Aktif' : 'Durduruldu',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: med.isActive ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
