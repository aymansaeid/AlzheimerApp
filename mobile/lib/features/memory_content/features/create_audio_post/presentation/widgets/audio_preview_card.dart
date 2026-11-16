import 'package:flutter/material.dart';

class AudioPreviewCard extends StatefulWidget {
  final Duration position;
  final Duration total;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final Future<void> Function() onPauseAudio;
  final Future<void> Function() onPlayAudio;
  final Future<void> Function(Duration) onSeek;
  final VoidCallback onDiscard;

  const AudioPreviewCard({
    super.key,
    required this.position,
    required this.total,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.onPauseAudio,
    required this.onPlayAudio,
    required this.onSeek,
    required this.onDiscard,
  });

  @override
  State<AudioPreviewCard> createState() => _AudioPreviewCardState();
}

class _AudioPreviewCardState extends State<AudioPreviewCard> {
  bool _isDragging = false;
  bool _wasPlayingBeforeDrag = false;
  double _dragValue = 0.0;

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = widget.total.inMilliseconds.toDouble();
    final maxMs = totalMs > 0 ? totalMs : 1.0;

    // Total süre henüz kesinleşmediyse veya 0 ise pozisyonu 0'da tut (zıplama koruması)
    final posMs = widget.position.inMilliseconds.toDouble();
    final safeCurrent = totalMs > 0 ? posMs.clamp(0.0, maxMs) : 0.0;
    final currentMs = _isDragging ? _dragValue : safeCurrent;

    final showPlaying = !_isDragging && widget.isPlaying;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  child: IconButton(
                    icon: Icon(
                      showPlaying ? Icons.pause : Icons.play_arrow,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                    onPressed: widget.onTogglePlay,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: currentMs,
                      max: maxMs,
                      onChangeStart: (val) {
                        _wasPlayingBeforeDrag = widget.isPlaying;
                        _isDragging = true;
                        _dragValue = val;
                        if (_wasPlayingBeforeDrag) {
                          widget.onPauseAudio();
                        }
                        setState(() {});
                      },
                      onChanged: (val) {
                        setState(() {
                          _dragValue = val;
                        });
                      },
                      onChangeEnd: (val) async {
                        final target = Duration(milliseconds: val.toInt());
                        await widget.onSeek(target);

                        if (mounted) {
                          setState(() {
                            _isDragging = false;
                          });
                        }

                        if (_wasPlayingBeforeDrag) {
                          widget.onPlayAudio();
                        }
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: widget.onDiscard,
                  tooltip: 'Kaydı Sil',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 64, right: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _format(
                      _isDragging
                          ? Duration(milliseconds: _dragValue.toInt())
                          : widget.position,
                    ),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    _format(widget.total),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
