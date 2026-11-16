import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../../core/services/audio_record_service.dart';
import '../../../../../../core/services/permission_service.dart';
import '../../../feed/domain/entities/post.dart';
import '../../../feed/domain/usecases/add_post_usecase.dart';
import 'record_audio_state.dart';

@injectable
class RecordAudioCubit extends Cubit<RecordAudioState> {
  final AudioRecordService _audioService;
  final PermissionService _permissionService;
  final AddPostUseCase _addPostUseCase;

  Timer? _timer;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _playerPositionSub;
  Duration _lastDisplayedPreviewPosition = Duration.zero;

  RecordAudioCubit(
    this._audioService,
    this._permissionService,
    this._addPostUseCase,
  ) : super(const RecordAudioState()) {
    _listenPlayerStreams();
  }

  // features/create_audio_post/presentation/cubit/record_audio_cubit.dart

  void _listenPlayerStreams() {
    _playerStateSub = _audioService.playerStateStream.listen((
      playerState,
    ) async {
      final isPlaying =
          playerState.playing &&
          playerState.processingState != ProcessingState.completed;

      // Ses bittiğinde player'ı DISPOSE ETME! Yalnızca durdur ve başa al.
      if (playerState.processingState == ProcessingState.completed) {
        await _audioService.stopPreview();
        _lastDisplayedPreviewPosition = Duration.zero;
        emit(
          state.copyWith(
            isPreviewPlaying: false,
            previewPosition: Duration.zero,
          ),
        );
        return;
      }

      emit(state.copyWith(isPreviewPlaying: isPlaying));
    });

    _playerPositionSub = _audioService.playerPositionStream.listen((pos) {
      if (pos < _lastDisplayedPreviewPosition) {
        return;
      }
      if (state.previewTotalDuration > Duration.zero &&
          pos >= state.previewTotalDuration) {
        return;
      }
      _lastDisplayedPreviewPosition = pos;
      emit(state.copyWith(previewPosition: _lastDisplayedPreviewPosition));
    });
  }

  Future<void> startRecording() async {
    final hasPermission = await _permissionService
        .requestMicrophonePermission();
    if (!hasPermission) {
      emit(state.copyWith(permissionDenied: true));
      return;
    }

    // 1. Önce mikrofon donanımının ve AVAudioSession'ın tamamen açılmasını bekle
    await _audioService.startRecording();

    // 2. Mikrofon gerçekten kayda başladığı an UI'ı güncelle ve sayacı başlat
    emit(
      state.copyWith(
        permissionDenied: false,
        step: RecordStep.recording,
        recordDuration: Duration.zero,
      ),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      emit(
        state.copyWith(
          recordDuration: state.recordDuration + const Duration(seconds: 1),
        ),
      );
    });
  }

  Future<void> pauseRecording() async {
    _timer?.cancel();
    await _audioService.pauseRecording();
    emit(state.copyWith(step: RecordStep.paused));
  }

  Future<void> resumeRecording() async {
    await _audioService.resumeRecording();
    _startTimer();
    emit(state.copyWith(step: RecordStep.recording));
  }

  Future<void> stopRecording() async {
    _timer?.cancel();
    final path = await _audioService.stopRecording();

    if (isClosed) return;

    if (path != null) {
      await _audioService.initPlayer(path);
      final total = _audioService.playerTotalDuration ?? state.recordDuration;
      _lastDisplayedPreviewPosition = Duration.zero;

      if (isClosed) return;
      emit(
        state.copyWith(
          step: RecordStep.review,
          audioPath: () => path,
          previewTotalDuration: total,
          previewPosition: Duration.zero,
        ),
      );
    } else {
      emit(
        state.copyWith(
          step: RecordStep.failure,
          errorMessage: () => 'Ses kaydı alınamadı.',
        ),
      );
    }
  }

  Future<void> discardRecording() async {
    _timer?.cancel();
    await _audioService.cancelRecording();
    await _audioService.disposePlayer();

    if (isClosed) return;

    emit(const RecordAudioState(step: RecordStep.initial));
  }

  Future<void> togglePlayPreview() async {
    if (state.isPreviewPlaying) {
      await _audioService.pausePreview();
    } else {
      await _audioService.playPreview();
    }
  }

  Future<void> seekPreview(Duration position) async {
    await _audioService.seekPreview(position);
    _lastDisplayedPreviewPosition = position;
    emit(state.copyWith(previewPosition: position));
  }

  Future<void> openAppSettings() async {
    await _permissionService.openSettings();
  }

  Future<void> submitAudioPost() async {
    if (state.audioPath == null || state.step == RecordStep.submitting) return;

    emit(state.copyWith(step: RecordStep.submitting));

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: PostType.audio,
      createdAt: DateTime.now(),
      audioUrl: state.audioPath,
      audioDuration: state.previewTotalDuration,
      userId: 'user_1',
      userName: 'Ekrem',
    );

    final result = await _addPostUseCase(newPost);

    result.fold(
      (failure) => emit(
        state.copyWith(
          step: RecordStep.failure,
          errorMessage: () => failure.message,
        ),
      ),
      (_) => emit(state.copyWith(step: RecordStep.success)),
    );
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _playerStateSub?.cancel();
    await _playerPositionSub?.cancel();

    if (state.step == RecordStep.recording || state.step == RecordStep.paused) {
      await _audioService.cancelRecording();
    }
    await _audioService.disposePlayer();
    return super.close();
  }
}
