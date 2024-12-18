import 'dart:developer';

import 'package:flutter_soloud/flutter_soloud.dart';

class AudioManager {
  late SoLoud _soloud;
  final Map<String, AudioSource> _audioSources = {};

  AudioManager() {
    _soloud = SoLoud.instance;
  }

  SoLoud get soloud => _soloud;

  Future<void> loadAudio(String key, String path) async {
    try {
      final audioSource = await _soloud.loadFile(path);
      _audioSources[key] = audioSource;
    } catch (e) {
      log('Error loading audio: $e');
    }
  }

  void play(String key) {
    final audioSource = _audioSources[key];
    if (audioSource != null) {
      _soloud.play(audioSource);
    } else {
      log('Audio source not found for key: $key');
    }
  }

  void dispose() {
    _audioSources.clear();
    _soloud.disposeAllSources();
  }
}
