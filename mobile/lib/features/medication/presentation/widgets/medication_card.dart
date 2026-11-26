import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/medicine_log.dart';

class MedicationCard extends StatelessWidget {
  final MedicineLog medication;
  final VoidCallback onTap;
  final VoidCallback? onMarkAsTaken;
  final bool isPatient;
  final DateTime? currentDateTime;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.onTap,
    this.onMarkAsTaken,
    required this.isPatient,
    this.currentDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final scheduledLocal = medication.scheduledAt.toLocal();
    final timeStr = DateFormat('HH:mm').format(scheduledLocal);
    final isPending = medication.status == 0;
    final isTaken = medication.status == 1;
    final isMissed = medication.status == 2;

    // Parse scheduled time and convert to local time
    final now = currentDateTime ?? DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final scheduledDay = DateTime(
      scheduledLocal.year,
      scheduledLocal.month,
      scheduledLocal.day,
    );
    final isFuture = scheduledLocal.isAfter(now);
    final isPastDay = scheduledDay.isBefore(todayStart);

    // Role Check via constructor parameter

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Pill Icon with background
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isTaken
                          ? Colors.green.withValues(alpha: 0.1)
                          : isMissed
                              ? Colors.red.withValues(alpha: 0.1)
                              : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication,
                      color: isTaken
                          ? Colors.green
                          : isMissed
                              ? Colors.red
                              : Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.medicineName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medication.dosage,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Scheduled Time
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Status Badge or Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isPending) ...[
                    if (isPatient) ...[
                      if (isPastDay) ...[
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Bu ilaç zamanında alınmadı',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      ElevatedButton.icon(
                        onPressed: isFuture ? null : onMarkAsTaken,
                        icon: const Icon(Icons.check, size: 16, color: Colors.white),
                        label: Text(
                          isFuture ? 'Saati Gelmedi' : 'Alındı Yap',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPastDay ? Colors.red : Colors.green,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ] else if (isPastDay)
                      Flexible(
                        child: _buildStatusBadge(
                          icon: Icons.warning_amber_rounded,
                          label: 'Bu ilaç zamanında alınmadı',
                          color: Colors.red,
                        ),
                      )
                    else
                      _buildStatusBadge(
                        icon: Icons.hourglass_empty,
                        label: 'Bekliyor',
                        color: Colors.orange,
                      ),
                  ] else if (isTaken)
                    _buildStatusBadge(
                      icon: Icons.check_circle,
                      label: 'Alındı',
                      color: Colors.green,
                    )
                  else if (isMissed)
                    _buildStatusBadge(
                      icon: Icons.error,
                      label: 'Kaçırıldı',
                      color: Colors.red,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
