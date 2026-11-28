import 'package:flutter/material.dart';

class SafetyStatusCard extends StatelessWidget {
  final bool? isPatientSafe;
  final bool hasLocationData;
  final int? batteryLevel;
  final bool? isCharging;
  final String patientName;
  final VoidCallback? onTap;

  const SafetyStatusCard({
    super.key,
    this.isPatientSafe,
    this.hasLocationData = false,
    this.batteryLevel,
    this.isCharging,
    required this.patientName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isSafe = isPatientSafe ?? true;

    final Color bgColor;
    final Color accentColor;
    final Color borderColor;
    final IconData statusIcon;
    final String statusText;

    if (!hasLocationData) {
      bgColor = Colors.orange.shade50;
      accentColor = Colors.orange.shade800;
      borderColor = Colors.orange.shade200;
      statusIcon = Icons.location_searching_rounded;
      statusText = '$patientName için henüz konum verisi alınmadı.';
    } else if (isSafe) {
      bgColor = Colors.green.shade50;
      accentColor = Colors.green.shade800;
      borderColor = Colors.green.shade200;
      statusIcon = Icons.verified_user_rounded;
      statusText = '$patientName güvenli bölgede.';
    } else {
      bgColor = theme.colorScheme.errorContainer;
      accentColor = theme.colorScheme.error;
      borderColor = theme.colorScheme.error.withValues(alpha: 0.45);
      statusIcon = Icons.warning_amber_rounded;
      statusText = '$patientName güvenli bölge dışında!';
    }

    final battery = batteryLevel;
    final charging = isCharging == true;
    final bool isLowBattery = battery != null && battery < 20;

    final String batteryLabel = battery == null
        ? 'Pil: —'
        : charging
            ? 'Pil: %$battery (Şarj oluyor)'
            : 'Pil: %$battery';

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: accentColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konum ve Güvenli Alan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          charging
                              ? Icons.battery_charging_full_rounded
                              : (isLowBattery
                                  ? Icons.battery_alert_rounded
                                  : Icons.battery_std_rounded),
                          size: 16,
                          color: isLowBattery
                              ? theme.colorScheme.error
                              : accentColor.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          batteryLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: accentColor.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: accentColor.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
