import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class _MapAppOption {
  final String name;
  final Uri uri;
  final IconData icon;
  final Color color;

  const _MapAppOption({
    required this.name,
    required this.uri,
    required this.icon,
    required this.color,
  });
}

/// Resolves installed native map/navigation applications on iOS and Android
/// and opens directions directly, prompting the user when multiple apps exist.
class MapAppPicker {
  MapAppPicker._();

  static Future<void> openDirections(
    BuildContext context, {
    required double latitude,
    required double longitude,
    required String destinationName,
  }) async {
    final candidates = _buildCandidates(latitude, longitude);
    final availability = await Future.wait(
      candidates.map((option) => _canLaunch(option.uri)),
    );

    final available = <_MapAppOption>[
      for (var i = 0; i < candidates.length; i++)
        if (availability[i]) candidates[i],
    ];

    if (available.length >= 2) {
      if (!context.mounted) return;
      final selected = await _showPickerSheet(
        context,
        destinationName: destinationName,
        options: available,
      );
      if (selected != null) {
        final launched = await _tryLaunch(selected.uri);
        if (!launched && context.mounted) {
          _showError(context);
        }
      }
      return;
    }

    if (available.length == 1) {
      final launched = await _tryLaunch(available.first.uri);
      if (!launched && context.mounted) {
        _showError(context);
      }
      return;
    }

    // Fallback when no known native scheme reported availability.
    if (defaultTargetPlatform == TargetPlatform.android) {
      final geoUri = Uri.parse(
        'geo:0,0?q=$latitude,$longitude(${Uri.encodeComponent(destinationName)})',
      );
      if (await _tryLaunch(geoUri)) return;
    }

    final webFallback = defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.parse('https://maps.apple.com/?daddr=$latitude,$longitude')
        : Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
          );

    if (await _tryLaunch(webFallback)) return;

    if (context.mounted) {
      _showError(context);
    }
  }

  static List<_MapAppOption> _buildCandidates(
    double latitude,
    double longitude,
  ) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return [
        _MapAppOption(
          name: 'Apple Haritalar',
          uri: Uri.parse('maps://?daddr=$latitude,$longitude&dirflg=d'),
          icon: Icons.map_rounded,
          color: Colors.blue.shade700,
        ),
        _MapAppOption(
          name: 'Google Maps',
          uri: Uri.parse(
            'comgooglemaps://?daddr=$latitude,$longitude&directionsmode=driving',
          ),
          icon: Icons.location_on_rounded,
          color: Colors.green.shade700,
        ),
        _MapAppOption(
          name: 'Yandex Navigasyon',
          uri: Uri.parse(
            'yandexnavi://build_route_on_map?lat_to=$latitude&lon_to=$longitude',
          ),
          icon: Icons.navigation_rounded,
          color: Colors.amber.shade800,
        ),
        _MapAppOption(
          name: 'Yandex Haritalar',
          uri: Uri.parse(
            'yandexmaps://maps.yandex.com/?rtext=~$latitude,$longitude&rtt=auto',
          ),
          icon: Icons.explore_rounded,
          color: Colors.red.shade600,
        ),
        _MapAppOption(
          name: 'Waze',
          uri: Uri.parse('waze://?ll=$latitude,$longitude&navigate=yes'),
          icon: Icons.alt_route_rounded,
          color: Colors.lightBlue.shade600,
        ),
      ];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return [
        _MapAppOption(
          name: 'Google Maps',
          uri: Uri.parse('google.navigation:q=$latitude,$longitude&mode=d'),
          icon: Icons.location_on_rounded,
          color: Colors.green.shade700,
        ),
        _MapAppOption(
          name: 'Yandex Navigasyon',
          uri: Uri.parse(
            'yandexnavi://build_route_on_map?lat_to=$latitude&lon_to=$longitude',
          ),
          icon: Icons.navigation_rounded,
          color: Colors.amber.shade800,
        ),
        _MapAppOption(
          name: 'Yandex Haritalar',
          uri: Uri.parse(
            'yandexmaps://maps.yandex.com/?rtext=~$latitude,$longitude&rtt=auto',
          ),
          icon: Icons.explore_rounded,
          color: Colors.red.shade600,
        ),
        _MapAppOption(
          name: 'Waze',
          uri: Uri.parse('waze://?ll=$latitude,$longitude&navigate=yes'),
          icon: Icons.alt_route_rounded,
          color: Colors.lightBlue.shade600,
        ),
      ];
    }

    return const [];
  }

  static Future<bool> _canLaunch(Uri uri) async {
    try {
      return await canLaunchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yol tarifi açılamadı.')),
    );
  }

  static Future<_MapAppOption?> _showPickerSheet(
    BuildContext context, {
    required String destinationName,
    required List<_MapAppOption> options,
  }) {
    return showModalBottomSheet<_MapAppOption>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Yol Tarifi Uygulaması Seçin',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (destinationName.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  destinationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              for (final option in options)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: option.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(option.icon, color: option.color, size: 22),
                  ),
                  title: Text(
                    option.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade500,
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(option),
                ),
            ],
          ),
        );
      },
    );
  }
}
