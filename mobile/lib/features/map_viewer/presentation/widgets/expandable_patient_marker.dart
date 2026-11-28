import 'package:flutter/material.dart';

import '../../domain/entities/patient_entity.dart';

class ExpandablePatientMarker extends StatelessWidget {
  final PatientEntity patient;
  final bool isSelected;
  final double scale;
  final VoidCallback onTap;

  const ExpandablePatientMarker({
    super.key,
    required this.patient,
    required this.isSelected,
    this.scale = 1.0,
    required this.onTap,
  });

  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildAvatar(double radius) {
    final trimmedUrl = patient.avatarUrl?.trim();
    final hasImage = trimmedUrl != null && trimmedUrl.isNotEmpty;
    final size = radius * 2;
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blueAccent.withValues(alpha: 0.15),
      child: Text(
        _getInitials(patient.name),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.65,
          color: Colors.blueAccent,
        ),
      ),
    );

    if (!hasImage) return fallback;

    return SizedBox(
      width: size,
      height: size,
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
    final isOut = patient.isOutOfSafeZone;
    final themeColor = isOut ? Colors.red : Colors.blueAccent;
    final effectiveScale = isSelected ? scale * 1.12 : scale;

    return GestureDetector(
      onTap: onTap,
      child: Transform.scale(
        scale: effectiveScale,
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isSelected ? 4 : 0),
              decoration: isSelected
                  ? BoxDecoration(
                      color: themeColor.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? Colors.black38 : Colors.black26,
                      blurRadius: isSelected ? 10 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildAvatar(26),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: themeColor, size: 24),
          ],
        ),
      ),
    );
  }
}
