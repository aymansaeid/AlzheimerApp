import 'package:flutter/material.dart';

import '../../domain/entities/patient_entity.dart';

class PatientHorizontalList extends StatelessWidget {
  final List<PatientEntity> patients;
  final String? selectedPatientId;
  final ValueChanged<PatientEntity> onPatientTap;

  const PatientHorizontalList({
    super.key,
    required this.patients,
    required this.selectedPatientId,
    required this.onPatientTap,
  });

  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildAvatar(PatientEntity patient) {
    final trimmedUrl = patient.avatarUrl?.trim();
    final hasImage = trimmedUrl != null && trimmedUrl.isNotEmpty;
    final fallback = CircleAvatar(
      radius: 22,
      backgroundColor: Colors.blueAccent.withValues(alpha: 0.15),
      child: Text(
        _getInitials(patient.name),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.blueAccent,
        ),
      ),
    );

    if (!hasImage) return fallback;

    return SizedBox(
      width: 44,
      height: 44,
      child: ClipOval(
        child: Image.network(
          trimmedUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: patients.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final patient = patients[index];
          final isSelected = patient.id == selectedPatientId;
          final isOut = patient.isOutOfSafeZone;
          final battery = patient.batteryLevel;
          final isLowBattery = battery != null && battery < 20;

          final borderColor = isOut
              ? Colors.red
              : (isSelected ? Colors.blueAccent : Colors.white);

          final IconData batteryIcon;
          final Color batteryColor;
          final String batteryText;

          if (battery == null) {
            batteryIcon = Icons.battery_unknown;
            batteryColor = isSelected ? Colors.white70 : Colors.grey[600]!;
            batteryText = '—';
          } else if (patient.isCharging) {
            batteryIcon = Icons.battery_charging_full;
            batteryColor = isSelected ? Colors.white70 : Colors.green[700]!;
            batteryText = '%$battery';
          } else if (isLowBattery) {
            batteryIcon = Icons.battery_alert;
            batteryColor = Colors.redAccent;
            batteryText = '%$battery';
          } else {
            batteryIcon = Icons.battery_std;
            batteryColor = isSelected ? Colors.white70 : Colors.grey[700]!;
            batteryText = '%$battery';
          }

          return GestureDetector(
            onTap: () => onPatientTap(patient),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blueAccent.withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      _buildAvatar(patient),
                      if (isOut)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            batteryIcon,
                            size: 14,
                            color: batteryColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            batteryText,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
