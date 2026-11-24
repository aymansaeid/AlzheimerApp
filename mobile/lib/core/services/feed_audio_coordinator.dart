import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';

@lazySingleton
class FeedAudioCoordinator {
  String? _activePostId;
  AudioPlayer? _activePlayer;

  void play(String postId, AudioPlayer player) {
    // Eğer halihazırda başka bir ses çalıyorsa, onu duraklat
    if (_activePostId != null && _activePostId != postId) {
      _activePlayer?.pause();
    }

    _activePostId = postId;
    _activePlayer = player;
  }

  void pause(String postId) {
    if (_activePostId == postId) {
      _activePlayer?.pause();
      _activePostId = null;
      _activePlayer = null;
    }
  }

  void stopAll() {
    _activePlayer?.pause();
    _activePostId = null;
    _activePlayer = null;
  }
}
