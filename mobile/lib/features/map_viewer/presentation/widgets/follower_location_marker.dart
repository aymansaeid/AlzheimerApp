import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class FollowerLocationMarker extends StatefulWidget {
  const FollowerLocationMarker({super.key});

  @override
  State<FollowerLocationMarker> createState() => _FollowerLocationMarkerState();
}

class _FollowerLocationMarkerState extends State<FollowerLocationMarker> {
  StreamSubscription<CompassEvent>? _compassSub;
  double? _heading;

  @override
  void initState() {
    super.initState();
    _compassSub = FlutterCompass.events?.listen(
      (event) {
        final next = event.heading;
        if (next == null || next.isNaN) return;
        if (_heading == null || (next - _heading!).abs() >= 1.0) {
          if (mounted) {
            setState(() {
              _heading = next;
            });
          }
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent.withValues(alpha: 0.25),
            ),
          ),
          if (_heading != null)
            Transform.rotate(
              angle: _heading! * (math.pi / 180.0),
              child: CustomPaint(
                size: const Size(64, 64),
                painter: _HeadingArrowPainter(),
              ),
            ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadingArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    const tipY = 4.0;
    const baseY = 17.0;
    const halfWidth = 7.5;

    final path = Path()
      ..moveTo(cx, tipY)
      ..lineTo(cx + halfWidth, baseY)
      ..lineTo(cx, baseY - 3.0)
      ..lineTo(cx - halfWidth, baseY)
      ..close();

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
