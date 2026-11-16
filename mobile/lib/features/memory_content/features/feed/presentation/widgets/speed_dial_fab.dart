import 'package:flutter/material.dart';

class SpeedDialFab extends StatefulWidget {
  final VoidCallback onRecordAudioTap;
  final VoidCallback onCreatePostTap;

  const SpeedDialFab({
    super.key,
    required this.onRecordAudioTap,
    required this.onCreatePostTap,
  });

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Metin etiketi
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Normal boyutta FAB (small yerine tam boy)
              FloatingActionButton(
                heroTag:
                    label, // Hero çakışmasını engellemek için benzersiz tag
                elevation: 3,
                onPressed: () {
                  _toggle();
                  onTap();
                },
                child: Icon(icon, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isOpen) ...[
          _buildItem(
            icon: Icons.mic,
            label: 'Ses Kaydı',
            onTap: widget.onRecordAudioTap,
          ),
          _buildItem(
            icon: Icons.edit_note,
            label: 'Gönderi',
            onTap: widget.onCreatePostTap,
          ),
        ],
        FloatingActionButton(
          heroTag: 'main_speed_dial_fab',
          onPressed: _toggle,
          child: AnimatedRotation(
            turns: _isOpen ? 0.125 : 0, // 45 derece dönerek 'X' olur
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }
}
