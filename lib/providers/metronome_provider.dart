import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/providers/audio_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetronomeProvider extends ChangeNotifier {
  final PlaylistProvider p;
  final AudioProvider a;

  MetronomeProvider(this.p, this.a) {
    p.addListener(() {
      notifyListeners();
    });
    a.addListener(() {
      notifyListeners();
    });
  }

  ClickData currentBeat = ClickData(time: 0, beat: 0);
  int currentBeatIndex = 0;
  int? _previousBeatIndex;
  int beatLength = 0;
  bool isLeft = true;
  bool isStarted = false;
  Timer? metronomeTimer;
  int lastUsedTempo = 0;
  bool metronomeMuted = true;
  double metronomeVolume = 0.5;
  bool metronomeBellEnabled = true;
  final int _metronomeOffesetDelay = 40; //milliseconds

  //GETTERS
  ClickData? get currentBeatData => currentClickData?.clickData != null &&
          currentClickData!.clickData.isNotEmpty &&
          currentClickData?.clickData[currentBeatIndex] != null
      ? currentClickData!.clickData[currentBeatIndex]
      : null;
  ClickData? get nextBeatData => currentClickData?.clickData[currentBeatIndex];
  SectionClickData? get currentClickData => p.playlistClickData.isNotEmpty &&
          p.playlist[p.currentSectionIndex].metronomeAvailable != null &&
          p.playlist[p.currentSectionIndex].metronomeAvailable!
      ? p.playlistClickData.firstWhere(
          (click) => click.sectionKey == p.playlist[p.currentSectionIndex].key)
      : null;
  PlaylistDuration? get currentPlaylistDuration =>
      p.currentPlaylistDurations.isNotEmpty &&
              p.playlist[p.currentSectionIndex].metronomeAvailable != null &&
              p.playlist[p.currentSectionIndex].metronomeAvailable!
          ? p.currentPlaylistDurations.firstWhere((element) =>
              element.sectionKey == p.playlist[p.currentSectionIndex].key)
          : null;
  List<int> get currentPlaylistDurationBeats =>
      currentPlaylistDuration?.beatLengths ?? [];
  bool get isFirstBeat => currentBeatData?.beat == 1;

  void setCurrentBeat() {
    if (currentBeatIndex < currentPlaylistDurationBeats.length - 1) {
      final index = currentClickData!.clickData.indexWhere((click) =>
          click.time / p.tempoDiff >= a.currentPosition.inMilliseconds);
      if (index == -1) {
        stopMetronome();
        return;
      }
      if (index > 0) {
        currentBeatIndex = index - 1;
        currentBeatIndex % 2 == 0 ? isLeft = true : isLeft = false;
        if (currentBeatIndex == -1) {
          isLeft = false;
        } else {
          setBeatLength();
        }
        if (_previousBeatIndex != currentBeatIndex &&
            currentBeatIndex != 0 &&
            !metronomeMuted) {
          Future.delayed(Duration(milliseconds: _metronomeOffesetDelay),
              () => playMetronomeSound());
          _previousBeatIndex = currentBeatIndex;
        }
      }
    } else {
      stopMetronome();
    }
  }

  void setBeatLength() {
    if (p.currentPlaylistDurationBeats.isNotEmpty) {
      beatLength =
          (p.currentPlaylistDurationBeats[currentBeatIndex] / p.tempoDiff)
              .round();
      notifyListeners();
    }
  }

  Future<void> playMetronomeSound() async {
    isFirstBeat && metronomeBellEnabled
        ? a.metronomeBellHandle = await a.player.play(a.metronomeBell!)
        : a.metronomeHandle = await a.player.play(a.metronomeClick!);

    setMetronomeVolume(metronomeVolume);
  }

  void startMetronome() {
    metronomeTimer?.cancel();
    currentBeatIndex = 0;
    isLeft = !isLeft;
    if (p.currentPlaylistDurationBeats.isNotEmpty) setBeatLength();
    isStarted = true;
    notifyListeners();
  }

  void playMetronome() {
    if (currentBeatIndex < p.currentPlaylistDurationBeats.length - 1) {
      setCurrentBeat();
    } else {
      stopMetronome();
    }
    notifyListeners();
  }

  void stopMetronome() {
    metronomeTimer?.cancel();
    isStarted = false;
    beatLength = 0;
    currentBeatIndex = 0;
    notifyListeners();
  }

  void setMetronomeMuted() async {
    metronomeMuted = !metronomeMuted;
    if (a.metronomeHandle != null) {
      a.player.setVolume(a.metronomeHandle!, metronomeVolume);
    }
    if (a.metronomeBellHandle != null) {
      a.player.setVolume(a.metronomeBellHandle!, metronomeVolume);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('metronomeMuted', metronomeMuted);
  }

  void setMetronomeBellEnabled() async {
    metronomeBellEnabled = !metronomeBellEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('metronomeBellEnabled', metronomeBellEnabled);
  }

  void getMetronomeBellEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    metronomeBellEnabled = prefs.getBool('metronomeBellEnabled') ?? true;
    notifyListeners();
  }

  void getMetronomeMuted() async {
    final prefs = await SharedPreferences.getInstance();
    metronomeMuted = prefs.getBool('metronomeMuted') ?? true;
    notifyListeners();
  }

  void setMetronomeVolume(double value) async {
    final double metronomeAttenuation = 1;
    metronomeVolume = value;
    value == 0 ? metronomeMuted = true : metronomeMuted = false;
    notifyListeners();

    if (a.metronomeHandle != null) {
      a.player.setVolume(
          a.metronomeHandle!, metronomeVolume * metronomeAttenuation);
    }
    if (a.metronomeBellHandle != null) {
      a.player.setVolume(
          a.metronomeBellHandle!, metronomeVolume * metronomeAttenuation);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('metronomeVolume', metronomeVolume);
  }

  void getMetronomeVolume() async {
    final prefs = await SharedPreferences.getInstance();
    metronomeVolume = prefs.getDouble('metronomeVolume') ?? 0.5;
    notifyListeners();
  }

  void resetMetronomeVolume() async {
    metronomeVolume = 0.5;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('metronomeVolume', metronomeVolume);
    setMetronomeVolume(metronomeVolume);
    notifyListeners();
  }

  void getMetronomeData() {
    getMetronomeMuted();
    getMetronomeVolume();
    getMetronomeBellEnabled();
  }
}
