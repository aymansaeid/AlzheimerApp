import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/safe_zone_calculator.dart';
import '../../domain/entities/patient_entity.dart';

class PatientQuickActionsBar extends StatelessWidget {
  final PatientEntity selectedPatient;
  final VoidCallback onClose;
  final VoidCallback onEditSafeZone;

  const PatientQuickActionsBar({
    super.key,
    required this.selectedPatient,
    required this.onClose,
    required this.onEditSafeZone,
  });

  String _getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildAvatar() {
    final trimmedUrl = selectedPatient.avatarUrl?.trim();
    final hasImage = trimmedUrl != null && trimmedUrl.isNotEmpty;
    const double radius = 22;
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blueAccent.withValues(alpha: 0.15),
      child: Text(
        _getInitials(selectedPatient.name),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.blueAccent,
        ),
      ),
    );

    if (!hasImage) return fallback;

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: ClipOval(
        child: Image.network(
          trimmedUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback,
        ),
      ),
    );
  }

  Future<void> _callPatient(BuildContext context) async {
    final phone = selectedPatient.phoneNumber?.trim();
    if (phone == null || phone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hastaya ait telefon numarası bulunamadı.'),
          ),
        );
      }
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _navigateToPatient(BuildContext context) async {
    final loc = selectedPatient.currentLocation;
    if (loc == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hastanın henüz konum bilgisi yok.')),
        );
      }
      return;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${loc.latitude},${loc.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final zone = selectedPatient.safeZone;
    final isOut = selectedPatient.isOutOfSafeZone;

    final Color themeColor;
    final Color statusColor;
    final String statusText;

    if (zone == null) {
      themeColor = Colors.orange;
      statusColor = Colors.orange.shade800;
      statusText = 'Güvenli Bölge Tanımsız';
    } else if (isOut) {
      themeColor = Colors.red;
      statusColor = Colors.red;
      statusText =
          '⚠️ Bölge Dışında! • ${SafeZoneCalculator.formatRadius(zone.radiusInMeters)}';
    } else {
      themeColor = Colors.blueAccent;
      statusColor = Colors.green.shade700;
      statusText =
          'Güvenli Bölgede • ${SafeZoneCalculator.formatRadius(zone.radiusInMeters)}';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedPatient.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: 'Kapat',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 22, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(
                      color: Colors.green.withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => _callPatient(context),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Ara', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    side: BorderSide(
                      color: Colors.blueAccent.withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => _navigateToPatient(context),
                  icon: const Icon(Icons.directions, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Yol Tarifi', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                  ),
                  onPressed: onEditSafeZone,
                  icon: const Icon(Icons.radar, size: 18),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Safe-Zone', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
