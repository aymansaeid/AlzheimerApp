import 'package:flutter/material.dart';

import '../../../../core/utils/safe_zone_calculator.dart';



class SafeZoneSetupOverlay extends StatelessWidget {
  static const double circleDiameter = 240.0;
  static const double circleRadius = circleDiameter / 2.0;

  final String patientName;
  final double currentRadiusInMeters;
  final bool hasExistingSafeZone;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onRemove;

  const SafeZoneSetupOverlay({
    super.key,
    required this.patientName,
    required this.currentRadiusInMeters,
    required this.hasExistingSafeZone,
    required this.onSave,
    required this.onCancel,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Ekranın tam merkezindeki sabit çember (Harita etkileşimini engellemez)
        Center(
          child: IgnorePointer(
            child: Container(
              width: circleDiameter,
              height: circleDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withValues(alpha: 0.18),
                border: Border.all(color: Colors.deepPurple, width: 2.5),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  color: Colors.deepPurple,
                  size: 28,
                ),
              ),
            ),
          ),
        ),

        // 2. Alt kısımdaki kontrol ve canlı bilgi kartı
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$patientName İçin Güvenli Bölge',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Haritayı yakınlaştırıp kaydırarak alanı çemberin içine sığdırın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Hesaplanan Yarıçap: ${SafeZoneCalculator.formatRadius(currentRadiusInMeters)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (hasExistingSafeZone) ...[
                        IconButton(
                          tooltip: 'Mevcut Bölgeyi Sil',
                          onPressed: onRemove,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: onSave,
                          child: const Text('Kaydet'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
