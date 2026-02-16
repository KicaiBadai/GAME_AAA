import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Status flags
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  bool _isMusicPlaying = false;

  // Volume settings
  double _musicVolume = 0.7;
  double _sfxVolume = 1.0;

  // Getters
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  bool get isMusicPlaying => _isMusicPlaying;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  /// Initialize audio system - preload all audio files
  Future<void> initialize() async {
    try {
      print('🎵 Initializing audio...');

      // Preload all audio files
      await FlameAudio.audioCache.loadAll([
        'music/background_music.mp3',
        'sfx/collect.mp3',
        'sfx/explosion.mp3',
        'sfx/jump.mp3',
      ]);

      print('✅ Audio initialized successfully');

      // Auto play musik setelah initialize (dengan delay)
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isMusicEnabled && !_isMusicPlaying) {
          playBackgroundMusic();
        }
      });
    } catch (e) {
      print('❌ Error initializing audio: $e');
    }
  }

  /// Play background music - VERSI AMAN UNTUK WEB
  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled) {
      print('🔇 Music disabled, not playing');
      return;
    }

    try {
      // Cek apakah sedang playing
      if (!_isMusicPlaying) {
        print('🎵 Attempting to play background music...');

        // Di web, play() mengembalikan Future yang harus ditunggu
        await FlameAudio.bgm.play(
          'music/background_music.mp3',
          volume: _musicVolume,
        );
        _isMusicPlaying = true;
        print('✅ Background music started');
      } else {
        print('🎵 Music already playing');
      }
    } catch (e) {
      print('❌ Error playing background music: $e');
      _isMusicPlaying = false;
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    try {
      await FlameAudio.bgm.stop();
      _isMusicPlaying = false;
      print('⏹️ Stopped background music');
    } catch (e) {
      print('❌ Error stopping background music: $e');
    }
  }

  /// Pause background music - VERSI AMAN
  Future<void> pauseBackgroundMusic() async {
    try {
      await FlameAudio.bgm.pause();
      _isMusicPlaying = false;
      print('⏸️ Paused background music');
    } catch (e) {
      print('❌ Error pausing background music: $e');
    }
  }

  /// Resume background music - VERSI AMAN
  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled) return;

    try {
      await FlameAudio.bgm.resume();
      _isMusicPlaying = true;
      print('▶️ Resumed background music');
    } catch (e) {
      print('⚠️ Resume failed, trying to play from start: $e');
      await playBackgroundMusic();
    }
  }

  /// Play sound effect
  void playSfx(String fileName) {
    if (!_isSfxEnabled) return;

    try {
      FlameAudio.play('sfx/$fileName', volume: _sfxVolume);
      print('🔊 Playing SFX: $fileName');
    } catch (e) {
      print('❌ Error playing SFX: $e');
    }
  }

  /// Play sound effect with custom volume
  void playSfxWithVolume(String fileName, double volume) {
    if (_isSfxEnabled) {
      try {
        final adjustedVolume = (volume * _sfxVolume).clamp(0.0, 1.0);
        FlameAudio.play('sfx/$fileName', volume: adjustedVolume);
        print('🔊 Playing SFX with volume: $fileName');
      } catch (e) {
        print('❌ Error playing SFX with volume: $e');
      }
    }
  }

  /// Set music volume (0.0 - 1.0)
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    try {
      FlameAudio.bgm.audioPlayer.setVolume(_musicVolume);
      print('🔊 Music volume set to: $_musicVolume');
    } catch (e) {
      print('❌ Error setting music volume: $e');
    }
  }

  /// Set sound effects volume (0.0 - 1.0)
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    print('🔊 SFX volume set to: $_sfxVolume');
  }

  /// Toggle music on/off - VERSI AMAN
  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    print('🔊 Music toggled: ${_isMusicEnabled ? "ON" : "OFF"}');

    if (_isMusicEnabled) {
      if (_isMusicPlaying) {
        await resumeBackgroundMusic();
      } else {
        await playBackgroundMusic();
      }
    } else {
      await pauseBackgroundMusic();
    }
  }

  /// Toggle sound effects on/off
  void toggleSfx() {
    _isSfxEnabled = !_isSfxEnabled;
    print(_isSfxEnabled ? '🔊 SFX enabled' : '🔇 SFX disabled');
  }

  /// Enable music
  void enableMusic() {
    if (!_isMusicEnabled) {
      _isMusicEnabled = true;
      print('🔊 Music enabled');
      playBackgroundMusic();
    }
  }

  /// Disable music
  void disableMusic() {
    if (_isMusicEnabled) {
      _isMusicEnabled = false;
      print('🔇 Music disabled');
      pauseBackgroundMusic();
    }
  }

  /// Enable sound effects
  void enableSfx() {
    _isSfxEnabled = true;
    print('🔊 SFX enabled');
  }

  /// Disable sound effects
  void disableSfx() {
    _isSfxEnabled = false;
    print('🔇 SFX disabled');
  }

  /// Cleanup and dispose audio resources
  void dispose() {
    try {
      FlameAudio.bgm.dispose();
      _isMusicPlaying = false;
      print('🧹 Audio resources disposed');
    } catch (e) {
      print('❌ Error disposing audio: $e');
    }
  }
}

// Global instance untuk mudah diakses
final audioManager = AudioManager();
