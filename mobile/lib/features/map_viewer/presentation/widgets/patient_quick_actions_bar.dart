import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/safe_zone_calculator.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/entities/safe_zone_entity.dart';
import 'map_app_picker_sheet.dart';

class PatientQuickActionsBar extends StatelessWidget {
  final PatientEntity selectedPatient;
  final String? focusedSafeZoneId;
  final bool canManageSafeZones;
  final VoidCallback onClose;
  final VoidCallback onAddSafeZone;
  final ValueChanged<SafeZoneEntity> onFocusSafeZone;
  final ValueChanged<SafeZoneEntity> onEditSafeZone;

  const PatientQuickActionsBar({
    super.key,
    required this.selectedPatient,
    this.focusedSafeZoneId,
    this.canManageSafeZones = false,
    required this.onClose,
    required this.onAddSafeZone,
    required this.onFocusSafeZone,
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
    final sanitized = phone?.replaceAll(RegExp(r'[^0-9+]'), '') ?? '';
    if (phone == null || phone.isEmpty || sanitized.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hastaya ait telefon numarası bulunamadı.'),
          ),
        );
      }
      return;
    }

    final uri = Uri(scheme: 'tel', path: sanitized);
    var launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bu cihazda arama başlatılamadı: $phone'),
          action: SnackBarAction(
            label: 'Kopyala',
            onPressed: () => Clipboard.setData(ClipboardData(text: phone)),
          ),
        ),
      );
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
    await MapAppPicker.openDirections(
      context,
      latitude: loc.latitude,
      longitude: loc.longitude,
      destinationName: selectedPatient.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final zones = selectedPatient.safeZones;
    final SafeZoneEntity? focusedZone = focusedSafeZoneId == null
        ? null
        : zones.cast<SafeZoneEntity?>().firstWhere(
            (z) => z?.id == focusedSafeZoneId,
            orElse: () => null,
          );
    final isOut = selectedPatient.isOutOfSafeZone;

    final Color themeColor;
    final Color statusColor;
    final String statusText;

    if (zones.isEmpty) {
      themeColor = Colors.orange;
      statusColor = Colors.orange.shade800;
      statusText = 'Güvenli Bölge Tanımsız';
    } else if (isOut) {
      themeColor = Colors.red;
      statusColor = Colors.red;
      statusText = '⚠️ Bölge Dışında! • ${zones.length} bölge';
    } else {
      themeColor = Colors.blueAccent;
      statusColor = Colors.green.shade700;
      statusText = 'Güvenli Bölgede • ${zones.length} bölge';
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
          if (zones.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: canManageSafeZones ? zones.length + 1 : zones.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == zones.length) {
                    return InkWell(
                      onTap: onAddSafeZone,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.deepPurple.withValues(alpha: 0.35),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Ekle',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final zone = zones[index];
                  final isFocused = zone.id == focusedSafeZoneId;
                  final zoneBorderColor = isOut
                      ? Colors.red.withValues(alpha: 0.35)
                      : Colors.deepPurple.withValues(alpha: 0.28);
                  final zoneIconColor = isOut ? Colors.red : Colors.deepPurple;

                  return InkWell(
                    onTap: () => onFocusSafeZone(zone),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isFocused
                            ? zoneIconColor
                            : zoneIconColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isFocused ? zoneIconColor : zoneBorderColor,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.radar,
                            size: 14,
                            color: isFocused ? Colors.white : zoneIconColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${zone.name} • ${SafeZoneCalculator.formatRadius(zone.radiusInMeters)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isFocused ? Colors.white : zoneIconColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
              if (canManageSafeZones) ...[
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
                    onPressed: focusedZone != null
                        ? () => onEditSafeZone(focusedZone)
                        : onAddSafeZone,
                    icon: Icon(
                      focusedZone != null
                          ? Icons.edit_outlined
                          : Icons.add_location_alt_outlined,
                      size: 18,
                    ),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        focusedZone != null
                            ? 'Düzenle'
                            : (zones.isEmpty ? 'Safe-Zone Ekle' : 'Yeni Bölge'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
