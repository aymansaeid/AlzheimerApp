import 'package:flutter/material.dart';

class PulseRecordButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const PulseRecordButton({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  @override
  State<PulseRecordButton> createState() => _PulseRecordButtonState();
}

class _PulseRecordButtonState extends State<PulseRecordButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isRecording) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulseRecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isRecording ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.shade700,
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(
                  alpha: widget.isRecording ? 0.45 : 0.25,
                ),
                blurRadius: widget.isRecording ? 24 : 10,
                spreadRadius: widget.isRecording ? 6 : 2,
              ),
            ],
          ),
          child: Icon(
            widget.isRecording ? Icons.mic : Icons.mic_none,
            color: Colors.white,
            size: 38,
          ),
        ),
      ),
    );
  }
}
