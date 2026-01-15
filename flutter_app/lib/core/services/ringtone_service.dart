import 'package:audioplayers/audioplayers.dart';

class RingtoneService {
  static final RingtoneService _instance = RingtoneService._internal();
  factory RingtoneService() => _instance;
  RingtoneService._internal();

  AudioPlayer? _player;
  bool _isPlaying = false;

  /// Play a modern polyphonic ringtone
  Future<void> playRingtone() async {
    if (_isPlaying) {
      print('⚠️ Ringtone already playing');
      return;
    }

    try {
      print('🔔 Starting ringtone...');
      _isPlaying = true;
      
      // Create new player instance
      _player = AudioPlayer();
      
      // Set audio mode for ringtone
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(1.0);
      
      // Set audio context for Android
      await _player!.setPlayerMode(PlayerMode.mediaPlayer);
      
      // Play the ringtone
      print('🎵 Loading asset: sounds/ringtone.mp3');
      await _player!.play(
        AssetSource('sounds/ringtone.mp3'),
      );
      
      // Listen to player state
      _player!.onPlayerStateChanged.listen((state) {
        print('🎵 Player state: $state');
      });
      
      _player!.onPlayerComplete.listen((event) {
        print('🎵 Playback completed (should loop)');
      });
      
      print('✅ Ringtone started successfully');
    } catch (e, stackTrace) {
      print('❌ Error playing ringtone: $e');
      print('Stack trace: $stackTrace');
      _isPlaying = false;
      _player?.dispose();
      _player = null;
    }
  }

  /// Stop the ringtone
  Future<void> stopRingtone() async {
    if (!_isPlaying) {
      print('⚠️ Ringtone not playing');
      return;
    }

    try {
      print('🔕 Stopping ringtone...');
      await _player?.stop();
      await _player?.dispose();
      _player = null;
      _isPlaying = false;
      print('✅ Ringtone stopped');
    } catch (e) {
      print('❌ Error stopping ringtone: $e');
      _isPlaying = false;
    }
  }

  /// Dispose resources
  void dispose() {
    _player?.dispose();
    _player = null;
    _isPlaying = false;
  }
}
