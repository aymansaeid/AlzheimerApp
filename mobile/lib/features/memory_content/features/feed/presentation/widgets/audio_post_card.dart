import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../../core/services/feed_audio_coordinator.dart';
import '../../domain/entities/memory_content.dart';
import '../../domain/entities/post.dart';
import 'post_header_widget.dart';

class AudioPostCard extends StatefulWidget {
  final MemoryContent memory;
  final Duration? audioDuration;
  final bool canDelete;
  final VoidCallback? onDelete;

  const AudioPostCard({
    super.key,
    required this.memory,
    this.audioDuration,
    this.canDelete = false,
    this.onDelete,
  });

  factory AudioPostCard.fromPost({
    Key? key,
    required Post post,
    bool canDelete = false,
    VoidCallback? onDelete,
  }) {
    return AudioPostCard(
      key: key,
      memory: MemoryContent(
        id: post.id,
        patientId: '',
        fileUrl: post.audioUrl ?? '',
        title: post.title,
        description: post.content,
        relationship: post.userName,
        contentType: MemoryContentType.voice,
        isActive: true,
        createdAt: post.createdAt.toIso8601String(),
        uploaderId: post.userId,
      ),
      audioDuration: post.audioDuration,
      canDelete: canDelete,
      onDelete: onDelete,
    );
  }

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
    final url = widget.memory.fileUrl;
    if (url.isEmpty) return;

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
        _coordinator.pause(widget.memory.id);
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
    _coordinator.pause(widget.memory.id);
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
    final total = widget.audioDuration ?? _player.duration ?? Duration.zero;
    final totalMs = total.inMilliseconds.toDouble();
    final maxMs = totalMs > 0 ? totalMs : 1.0;
    final createdAt =
        DateTime.tryParse(widget.memory.createdAt) ?? DateTime.now();
    final displayName = widget.memory.relationship.isNotEmpty
        ? widget.memory.relationship
        : 'Yakını';
    final hasTitle =
        widget.memory.title != null && widget.memory.title!.trim().isNotEmpty;
    final hasDescription = widget.memory.description != null &&
        widget.memory.description!.trim().isNotEmpty;

    return VisibilityDetector(
      key: Key('audio_memory_${widget.memory.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0.0 && _player.playing) {
          _player.pause();
          _coordinator.pause(widget.memory.id);
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
              userName: displayName,
              createdAt: createdAt,
              canDelete: widget.canDelete,
              onDelete: widget.onDelete,
            ),
            if (hasTitle || hasDescription)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasTitle)
                      Text(
                        widget.memory.title!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    if (hasDescription)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          widget.memory.description!,
                          style:
                              const TextStyle(fontSize: 13, height: 1.3),
                        ),
                      ),
                  ],
                ),
              ),
            const Divider(height: 1, thickness: 0.5),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data?.playing ?? false;
                  final isCompleted = snapshot.data?.processingState ==
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
                                        _coordinator.pause(widget.memory.id);
                                      } else {
                                        _coordinator.play(
                                          widget.memory.id,
                                          _player,
                                        );

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
                                final position =
                                    posSnap.data ?? Duration.zero;
                                if (position >= _lastDisplayedPosition) {
                                  _lastDisplayedPosition = position;
                                }
                                final posMs = _lastDisplayedPosition
                                    .inMilliseconds
                                    .toDouble();

                                final safeCurrent = totalMs > 0
                                    ? posMs.clamp(0.0, maxMs)
                                    : 0.0;

                                final current = _isDragging
                                    ? _dragValue
                                    : safeCurrent;

                                return SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3,
                                    thumbShape:
                                        const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape:
                                        const RoundSliderOverlayShape(
                                      overlayRadius: 12,
                                    ),
                                  ),
                                  child: Slider(
                                    value: current,
                                    max: maxMs,
                                    onChangeStart: (val) {
                                      _wasPlayingBeforeDrag =
                                          _player.playing;
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
                                          widget.memory.id,
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
                                  ? Duration(
                                      milliseconds: _dragValue.toInt(),
                                    )
                                  : (posSnap.data ??
                                      _lastDisplayedPosition);
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
