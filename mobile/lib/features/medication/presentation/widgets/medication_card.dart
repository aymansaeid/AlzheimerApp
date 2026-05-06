import 'package:flutter/material.dart';
import '../../domain/entities/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onTap;

  const MedicationCard({
    Key? key,
    required this.medication,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pill Icon with background
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: medication.isTaken
                      ? Colors.green.withOpacity(0.1)
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication,
                  color: medication.isTaken
                      ? Colors.green
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
                      medication.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medication.dosage} - ${medication.instructions}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Time and Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    medication.scheduleTime,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (medication.isTaken)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    )
                  else
                    const Icon(
                      Icons.access_time,
                      color: Colors.orange,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
