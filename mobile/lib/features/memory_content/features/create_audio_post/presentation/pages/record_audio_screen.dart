import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../../auth/presentation/bloc/auth_state.dart';
import '../../../../../caregiver/presentation/bloc/dashboard_bloc.dart';
import '../../../feed/domain/entities/memory_content.dart';
import '../../../feed/presentation/bloc/memory_bloc.dart';
import '../../../feed/presentation/bloc/memory_event.dart';
import '../../../feed/presentation/bloc/memory_state.dart';
import '../../../create_text_post/presentation/widgets/permission_denied_dialog.dart';
import '../cubit/record_audio_cubit.dart';
import '../cubit/record_audio_state.dart';
import '../widgets/audio_preview_card.dart';
import '../widgets/pusle_record_button.dart';
import '../widgets/record_timer_display.dart';

class RecordAudioScreen extends StatelessWidget {
  final String? patientId;

  const RecordAudioScreen({super.key, this.patientId});

  @override
  Widget build(BuildContext context) {
    bool hasMemoryBloc = false;
    try {
      context.read<MemoryBloc>();
      hasMemoryBloc = true;
    } catch (_) {}

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<RecordAudioCubit>()),
        if (!hasMemoryBloc) BlocProvider(create: (_) => getIt<MemoryBloc>()),
      ],
      child: _RecordAudioView(patientId: patientId),
    );
  }
}

class _RecordAudioView extends StatefulWidget {
  final String? patientId;

  const _RecordAudioView({this.patientId});

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

  void _submitAudio(BuildContext context, String audioPath) {
    // 1. Patient ID Çözümleme
    String targetPatientId = widget.patientId ?? '';
    if (targetPatientId.isEmpty) {
      final memoryState = context.read<MemoryBloc>().state;
      if (memoryState is MemoryLoaded && memoryState.patientId.isNotEmpty) {
        targetPatientId = memoryState.patientId;
      }
    }
    if (targetPatientId.isEmpty) {
      try {
        final dashboardState = context.read<DashboardBloc>().state;
        if (dashboardState is DashboardLoaded) {
          targetPatientId = dashboardState.summary.patientId;
        }
      } catch (_) {}
    }
    if (targetPatientId.isEmpty) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        targetPatientId = authState.user.id;
      }
    }

    // 2. Uploader ID ve Yakınlık / İsim Çözümleme
    String uploaderId = '';
    String relationship = 'Yakını';
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      uploaderId = authState.user.id;
      if (authState.user.fullName.isNotEmpty) {
        relationship = authState.user.fullName;
      }
    }

    // 3. MemoryBloc üzerinden ses kaydı gönderimi:
    // Ses dosyası Firebase Storage'a yüklenir, download URL backend'e iletilir.
    // Ses gönderisinde yazı ve resim koyulmaz (title = null, description = null).
    context.read<MemoryBloc>().add(
      CreateMemory(
        file: File(audioPath),
        patientId: targetPatientId,
        contentType: MemoryContentType.voice,
        title: null,
        description: null,
        relationship: relationship,
        uploaderId: uploaderId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MemoryBloc, MemoryState>(
      listener: (context, memoryState) {
        if (memoryState is MemoryOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(memoryState.message),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true); // Feed ekranına geri dön
        } else if (memoryState is MemoryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(memoryState.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocConsumer<RecordAudioCubit, RecordAudioState>(
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
        },
        builder: (context, state) {
          final isRecording = state.step == RecordStep.recording;
          final isPaused = state.step == RecordStep.paused;
          final isReview = state.step == RecordStep.review;

          final memoryState = context.watch<MemoryBloc>().state;
          final isSubmitting =
              memoryState is MemoryLoading ||
              (memoryState is MemoryLoaded && memoryState.isActionInProgress);

          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) async {
              if (!didPop) return;

              final cubit = context.read<RecordAudioCubit>();
              // Eğer kullanıcı kayıt alırken veya önizlemedeyken geri çıktıysa
              if (cubit.state.step == RecordStep.recording ||
                  cubit.state.step == RecordStep.paused ||
                  cubit.state.step == RecordStep.review) {
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : TextButton(
                              onPressed:
                                  (state.audioPath != null && !isSubmitting)
                                  ? () =>
                                        _submitAudio(context, state.audioPath!)
                                  : null,
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
                                context
                                    .read<RecordAudioCubit>()
                                    .startRecording();
                              } else if (isRecording) {
                                context
                                    .read<RecordAudioCubit>()
                                    .pauseRecording();
                              } else if (isPaused) {
                                context
                                    .read<RecordAudioCubit>()
                                    .resumeRecording();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 36),
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
                          onTogglePlay: isSubmitting
                              ? () {}
                              : () => context
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
                          onDiscard: isSubmitting
                              ? () {}
                              : () => context
                                    .read<RecordAudioCubit>()
                                    .discardRecording(),
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
      ),
    );
  }
}
