import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/di/injection.dart';
import '../../../create_text_post/presentation/widgets/permission_denied_dialog.dart';
import '../cubit/record_audio_cubit.dart';
import '../cubit/record_audio_state.dart';
import '../widgets/audio_preview_card.dart';
import '../widgets/pusle_record_button.dart';
import '../widgets/record_timer_display.dart';

class RecordAudioScreen extends StatelessWidget {
  const RecordAudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RecordAudioCubit>(),
      child: const _RecordAudioView(),
    );
  }
}

class _RecordAudioView extends StatefulWidget {
  const _RecordAudioView();

  @override
  State<_RecordAudioView> createState() => _RecordAudioViewState();
}

class _RecordAudioViewState extends State<_RecordAudioView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  bool _isStopping = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused &&
        state != AppLifecycleState.hidden) {
      return;
    }

    final cubit = context.read<RecordAudioCubit>();

    if (_isStopping ||
        cubit.isClosed ||
        cubit.state.step != RecordStep.recording) {
      return;
    }

    _isStopping = true;

    cubit.stopRecording().whenComplete(() {
      _isStopping = false;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecordAudioCubit, RecordAudioState>(
      listenWhen: (prev, current) =>
          prev.step != current.step ||
          prev.permissionDenied != current.permissionDenied,
      listener: (context, state) {
        if (state.permissionDenied) {
          showDialog(
            context: context,
            builder: (_) => PermissionDeniedDialog(
              onOpenSettings: () =>
                  context.read<RecordAudioCubit>().openAppSettings(),
            ),
          );
        }

        if (state.step == RecordStep.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ses kaydı başarıyla paylaşıldı!')),
          );
          context.pop(true);
        }

        if (state.step == RecordStep.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Bir hata oluştu.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isRecording = state.step == RecordStep.recording;
        final isPaused = state.step == RecordStep.paused;
        final isReview = state.step == RecordStep.review;
        final isSubmitting = state.step == RecordStep.submitting;

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) return;

            final cubit = context.read<RecordAudioCubit>();
            // Eğer kullanıcı kayıt alırken veya önizlemedeyken geri çıktıysa
            if (cubit.state.step == RecordStep.recording ||
                cubit.state.step == RecordStep.paused) {
              await cubit.discardRecording();
            } else if (cubit.state.step == RecordStep.review) {
              await cubit.discardRecording();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Ses Kaydı'),
              actions: [
                if (isReview)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: isSubmitting
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : TextButton(
                            onPressed: () => context
                                .read<RecordAudioCubit>()
                                .submitAudioPost(),
                            child: const Text(
                              'Gönder',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const Spacer(),

                    if (!isReview) ...[
                      RecordTimerDisplay(
                        duration: state.recordDuration,
                        isRecording: isRecording,
                      ),
                      const SizedBox(height: 48),
                      Center(
                        child: PulseRecordButton(
                          isRecording: isRecording,
                          onTap: () {
                            if (state.step == RecordStep.initial) {
                              context.read<RecordAudioCubit>().startRecording();
                            } else if (isRecording) {
                              context.read<RecordAudioCubit>().pauseRecording();
                            } else if (isPaused) {
                              context
                                  .read<RecordAudioCubit>()
                                  .resumeRecording();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Kayıt devam ederken veya duraklatıldığında alt aksiyon butonları
                      if (isRecording || isPaused)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(
                                isPaused ? Icons.play_arrow : Icons.pause,
                              ),
                              label: Text(isPaused ? 'Devam Et' : 'Duraklat'),
                              onPressed: () {
                                if (isPaused) {
                                  context
                                      .read<RecordAudioCubit>()
                                      .resumeRecording();
                                } else {
                                  context
                                      .read<RecordAudioCubit>()
                                      .pauseRecording();
                                }
                              },
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.stop),
                              label: const Text('Kaydet'),
                              onPressed: () => context
                                  .read<RecordAudioCubit>()
                                  .stopRecording(),
                            ),
                          ],
                        ),
                    ] else ...[
                      // Kayıt tamamlandıktan sonra önizleme kartı
                      AudioPreviewCard(
                        position: state.previewPosition,
                        total: state.previewTotalDuration,
                        isPlaying: state.isPreviewPlaying,
                        onTogglePlay: () => context
                            .read<RecordAudioCubit>()
                            .togglePlayPreview(),
                        onPauseAudio: () async {
                          if (context
                              .read<RecordAudioCubit>()
                              .state
                              .isPreviewPlaying) {
                            await context
                                .read<RecordAudioCubit>()
                                .togglePlayPreview();
                          }
                        },
                        onPlayAudio: () async {
                          if (!context
                              .read<RecordAudioCubit>()
                              .state
                              .isPreviewPlaying) {
                            await context
                                .read<RecordAudioCubit>()
                                .togglePlayPreview();
                          }
                        },
                        onSeek: (pos) =>
                            context.read<RecordAudioCubit>().seekPreview(pos),
                        onDiscard: () =>
                            context.read<RecordAudioCubit>().discardRecording(),
                      ),
                    ],

                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
