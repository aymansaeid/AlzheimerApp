import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/services/feed_audio_coordinator.dart';
import '../../domain/entities/post.dart';
import 'post_header_widget.dart';

class AudioPostCard extends StatefulWidget {
  final Post post;

  const AudioPostCard({super.key, required this.post});

  @override
  State<AudioPostCard> createState() => _AudioPostCardState();
}

class _AudioPostCardState extends State<AudioPostCard> {
  late final AudioPlayer _player;
  late final FeedAudioCoordinator _coordinator;

  bool _isInit = false;
  bool _isDragging = false;
  bool _wasPlayingBeforeDrag = false;
  double _dragValue = 0.0;
  Duration _lastDisplayedPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _coordinator = getIt<FeedAudioCoordinator>();
    _player = AudioPlayer();
    _initAudio();
    _listenPlayerEvents();
  }

  Future<void> _initAudio() async {
    final url = widget.post.audioUrl;
    if (url == null || url.isEmpty) return;

    try {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        await _player.setUrl(url);
      } else {
        await _player.setFilePath(url);
      }
      if (mounted) setState(() => _isInit = true);
    } catch (_) {}
  }

  void _listenPlayerEvents() {
    _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed) {
        await _player.pause();
        await _player.seek(Duration.zero);
        _lastDisplayedPosition = Duration.zero;
        _coordinator.pause(widget.post.id);
        if (mounted) {
          setState(() {
            _isDragging = false;
            _dragValue = 0.0;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _coordinator.pause(widget.post.id);
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final total =
        widget.post.audioDuration ?? _player.duration ?? Duration.zero;
    final totalMs = total.inMilliseconds.toDouble();
    final maxMs = totalMs > 0 ? totalMs : 1.0;

    return VisibilityDetector(
      key: Key('audio_post_${widget.post.id}'),
      onVisibilityChanged: (info) {
        // Kart ekrandan kaydırılarak çıktığında sesi duraklat
        if (info.visibleFraction == 0.0 && _player.playing) {
          _player.pause();
          _coordinator.pause(widget.post.id);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeaderWidget(
              userName: widget.post.userName,
              userAvatarUrl: widget.post.userProfileImageUrl,
              createdAt: widget.post.createdAt,
            ),
            const Divider(height: 1, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data?.playing ?? false;
                  final isCompleted =
                      snapshot.data?.processingState ==
                      ProcessingState.completed;

                  return Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: IconButton(
                              icon: Icon(
                                (isPlaying && !_isDragging)
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                              onPressed: !_isInit
                                  ? null
                                  : () async {
                                      if (isPlaying) {
                                        await _player.pause();
                                        _coordinator.pause(widget.post.id);
                                      } else {
                                        // 1. Önceki çalan ses varsa koordinatör üzerinden sustur
                                        _coordinator.play(
                                          widget.post.id,
                                          _player,
                                        );

                                        // 2. Ses bittiyse başa sar
                                        if (isCompleted ||
                                            (_player.duration != null &&
                                                _player.position >=
                                                    total -
                                                        const Duration(
                                                          milliseconds: 50,
                                                        ))) {
                                          await _player.seek(Duration.zero);
                                          _lastDisplayedPosition =
                                              Duration.zero;
                                        }
                                        _player.play();
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StreamBuilder<Duration>(
                              stream: _player.positionStream,
                              builder: (context, posSnap) {
                                final position = posSnap.data ?? Duration.zero;
                                if (position >= _lastDisplayedPosition) {
                                  _lastDisplayedPosition = position;
                                }
                                final posMs = _lastDisplayedPosition
                                    .inMilliseconds
                                    .toDouble();

                                // Duration henüz okunmadıysa pozisyonu 0.0'da tut (zıplama koruması)
                                final safeCurrent = totalMs > 0
                                    ? posMs.clamp(0.0, maxMs)
                                    : 0.0;

                                final current = _isDragging
                                    ? _dragValue
                                    : safeCurrent;

                                return SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 12,
                                    ),
                                  ),
                                  child: Slider(
                                    value: current,
                                    max: maxMs,
                                    onChangeStart: (val) {
                                      _wasPlayingBeforeDrag = _player.playing;
                                      _isDragging = true;
                                      _dragValue = val;
                                      if (_wasPlayingBeforeDrag) {
                                        _player.pause();
                                      }
                                      setState(() {});
                                    },
                                    onChanged: (val) {
                                      setState(() {
                                        _dragValue = val;
                                      });
                                    },
                                    onChangeEnd: (val) async {
                                      final target = Duration(
                                        milliseconds: val.toInt(),
                                      );
                                      await _player.seek(target);
                                      _lastDisplayedPosition = target;

                                      if (mounted) {
                                        setState(() {
                                          _isDragging = false;
                                        });
                                      }

                                      if (_wasPlayingBeforeDrag) {
                                        _coordinator.play(
                                          widget.post.id,
                                          _player,
                                        );
                                        _player.play();
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12, top: 2),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: StreamBuilder<Duration>(
                            stream: _player.positionStream,
                            builder: (context, posSnap) {
                              final currentDuration = _isDragging
                                  ? Duration(milliseconds: _dragValue.toInt())
                                  : (posSnap.data ?? _lastDisplayedPosition);
                              final displayedDuration =
                                  currentDuration >= _lastDisplayedPosition
                                  ? currentDuration
                                  : _lastDisplayedPosition;
                              return Text(
                                '${_formatDuration(displayedDuration)} / ${_formatDuration(total)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
