import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

abstract class AudioRecordService {
  Future<void> startRecording();
  Future<void> pauseRecording();
  Future<void> resumeRecording();
  Future<String?> stopRecording();
  Future<void> cancelRecording();

  Future<void> initPlayer(String filePath);
  Future<void> playPreview();
  Future<void> pausePreview();
  Future<void> seekPreview(Duration position);
  Future<void> stopPreview();
  Future<void> disposePlayer();

  Stream<PlayerState> get playerStateStream;
  Stream<Duration> get playerPositionStream;
  Duration? get playerTotalDuration;
}

@LazySingleton(as: AudioRecordService)
class AudioRecordServiceImpl implements AudioRecordService {
  AudioPlayer? _player;
  AudioRecorder? _recorder;
  String? _currentRecordingPath;

  final _playerStateController = StreamController<PlayerState>.broadcast();
  final _playerPositionController = StreamController<Duration>.broadcast();
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;

  AudioRecordServiceImpl();

  @override
  Future<void> startRecording() async {
    await disposePlayer();

    if (_recorder != null) {
      try {
        await _recorder!.dispose();
      } catch (_) {}
      _recorder = null;
    }

    _recorder = AudioRecorder();

    final appDir = await getApplicationDocumentsDirectory();
    final recordsDir = Directory('${appDir.path}/records');
    if (!await recordsDir.exists()) {
      await recordsDir.create(recursive: true);
    }

    final randomId = Random().nextInt(100000);
    final fileName =
        'rec_${DateTime.now().microsecondsSinceEpoch}_$randomId.m4a';
    _currentRecordingPath = '${recordsDir.path}/$fileName';

    // startRecording çağrıldığı an mikrofon doğrudan başlar (ekstra konfigürasyon gecikmesi yok)
    await _recorder!.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: _currentRecordingPath!,
    );
  }

  @override
  Future<void> pauseRecording() async {
    await _recorder?.pause();
  }

  @override
  Future<void> resumeRecording() async {
    await _recorder?.resume();
  }

  @override
  Future<String?> stopRecording() async {
    // Son kelimenin dosyaya akması için çok kısa bir emniyet payı
    await Future.delayed(const Duration(milliseconds: 150));

    final path = await _recorder?.stop();
    await _recorder?.dispose();
    _recorder = null;

    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (_) {}

    return path ?? _currentRecordingPath;
  }

  @override
  Future<void> cancelRecording() async {
    if (_recorder != null) {
      try {
        await _recorder!.stop();
        await _recorder!
            .dispose(); // Mikrofon oturumunu işletim sisteminden söker
      } catch (_) {}
      _recorder = null;
    }

    // İşletim sistemi ses oturumunu kapat
    try {
      final session = await AudioSession.instance;
      await session.setActive(false);
    } catch (_) {}

    // Diskte kalan geçici çöp dosyayı sil
    if (_currentRecordingPath != null) {
      try {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      _currentRecordingPath = null;
    }
  }

  @override
  Future<void> initPlayer(String filePath) async {
    await disposePlayer();

    _player = AudioPlayer();

    _stateSub = _player!.playerStateStream.listen((state) {
      if (!_playerStateController.isClosed) {
        _playerStateController.add(state);
      }
    });

    _posSub = _player!.positionStream.listen((pos) {
      if (!_playerPositionController.isClosed) {
        _playerPositionController.add(pos);
      }
    });

    try {
      await _player!.setFilePath(filePath);
    } on PlayerInterruptedException {
      // Kullanıcı dosya yüklenirken sayfadan çıktıysa bu hata gayet doğaldır, sessizce yok sayılır.
    } on PlayerException catch (_) {
      // Dosya bozuksa veya yüklenemediyse yakalanır
    } catch (_) {
      // Diğer olası iptal durumları
    }
  }

  @override
  Future<void> playPreview() async {
    if (_player == null) return;

    // Eğer tamamlandıysa veya sonuna geldiyse başa alıp çal
    if (_player!.processingState == ProcessingState.completed ||
        (_player!.duration != null &&
            _player!.position >=
                _player!.duration! - const Duration(milliseconds: 50))) {
      await _player!.seek(Duration.zero);
    }
    _player!.play();
  }

  @override
  Future<void> pausePreview() async {
    await _player?.pause();
  }

  @override
  Future<void> stopPreview() async {
    await _player?.stop();
    await _player?.seek(Duration.zero);
  }

  @override
  Future<void> seekPreview(Duration position) async {
    await _player?.seek(position);
  }

  @override
  Future<void> disposePlayer() async {
    await _stateSub?.cancel();
    await _posSub?.cancel();
    _stateSub = null;
    _posSub = null;

    if (_player != null) {
      try {
        await _player!.stop();
        await _player!.dispose();
      } catch (_) {}
      _player = null;
    }
  }

  @override
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;

  @override
  Stream<Duration> get playerPositionStream => _playerPositionController.stream;

  @override
  Duration? get playerTotalDuration => _player?.duration;
}
