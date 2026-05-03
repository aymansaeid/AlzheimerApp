import 'package:flutter/material.dart';

enum BadgeType { safe, alert, custom }

class StatusBadge extends StatelessWidget {
  final String? label;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showPulse;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.showPulse = false,
  }) : type = BadgeType.custom;

  const StatusBadge.safe({super.key, this.showPulse = true})
      : type = BadgeType.safe,
        label = null,
        backgroundColor = null,
        textColor = null;

  const StatusBadge.alert({super.key, this.showPulse = true})
      : type = BadgeType.alert,
        label = null,
        backgroundColor = null,
        textColor = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    String finalLabel;
    Color finalBg;
    Color finalText;
    
    switch (type) {
      case BadgeType.safe:
        finalLabel = 'Güvenli Alanda';
        finalBg = theme.colorScheme.primaryContainer;
        finalText = theme.colorScheme.onPrimaryContainer;
        break;
      case BadgeType.alert:
        finalLabel = 'Alan Dışında';
        finalBg = theme.colorScheme.errorContainer;
        finalText = theme.colorScheme.onErrorContainer;
        break;
      case BadgeType.custom:
        finalLabel = label!;
        finalBg = backgroundColor!;
        finalText = textColor!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: finalBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse) ...[
            _PulseDot(color: finalText),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              finalLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: finalText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
