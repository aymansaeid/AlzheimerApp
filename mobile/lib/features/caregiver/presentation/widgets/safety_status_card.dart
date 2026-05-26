import 'package:flutter/material.dart';

class SafetyStatusCard extends StatelessWidget {
  final bool isPatientSafe;
  final String patientName;

  const SafetyStatusCard({
    super.key,
    required this.isPatientSafe,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cardBgColor = isPatientSafe
        ? Colors.green.shade50
        : Colors.red.shade50;
    final contentColor = isPatientSafe
        ? Colors.green.shade800
        : Colors.red.shade800;
    final borderColor = isPatientSafe
        ? Colors.green.shade200
        : Colors.red.shade200;
    final icon = isPatientSafe
        ? Icons.verified_user_rounded
        : Icons.gpp_bad_rounded;
    final statusText = isPatientSafe
        ? 'Hasta Güvenli Alanda'
        : 'DİKKAT: Hasta Güvenli Alan Dışında!';
    final detailsText = isPatientSafe
        ? '$patientName için şu an herhangi bir risk bulunmuyor.'
        : 'Acil Durum! $patientName tanımlanan güvenli bölgeden ayrıldı!';

    return Card(
      elevation: 0,
      color: cardBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: InkWell(
        onTap: () {
          // context.pushNamed('patient_map');
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: contentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: contentColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: contentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      detailsText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: contentColor.withOpacity(0.85),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Haritada Görüntüle',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: contentColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: contentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
