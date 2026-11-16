import 'package:flutter/material.dart';

class RecordTimerDisplay extends StatelessWidget {
  final Duration duration;
  final bool isRecording;

  const RecordTimerDisplay({
    super.key,
    required this.duration,
    required this.isRecording,
  });

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRecording) ...[
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              _format(duration),
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w300,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isRecording ? 'Kayıt Yapılıyor...' : 'Kayda Hazır',
          style: TextStyle(
            fontSize: 13,
            color: isRecording ? Colors.redAccent : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
