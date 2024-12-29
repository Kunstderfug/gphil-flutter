import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:gphil/controllers/audio_manager.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioProvider extends ChangeNotifier {
  final PlaylistProvider p;

  AudioProvider(this.p) {
    p.addListener(() {
      notifyListeners();
    });
  }

// AUDIO PLAYERS
  List<PlayerAudioSource> playerAudioSources = [];
  final player = AudioManager().soloud;
  SoundHandle? activeHandle;
  SoundHandle? passiveHandle;
  final playerPool = <PlayerPool>[];
  Ticker ticker = Ticker((elapsed) {});
  double globalVolume = 1.0;
  double playerVolume = 1.0;
  double volumeMultiplier = 2.0;
  final GlobalLayerPlayerPool layerPlayersPool = GlobalLayerPlayerPool(
    globalLayers: [],
  );
  List<double> layersVolumes = <double>[0, 0, 0, 0];
  final layerPlayerPool = <LayerPlayerPool>[];
  bool layersEnabled = false;
  bool _isPlaying = false;

//AUDIOHANDLES
  SoundHandle? metronomeHandle;
  AudioSource? metronomeClick;
  AudioSource? metronomeBell;
  SoundHandle? metronomeBellHandle;

// Durations
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;

//AUTO CONTINUE
  int autoContinueOffset = 5000;
  bool doublePressGuard =
      true; // avoid pressing pedal twice by mistake and earlier than needed
  int?
      autoContinueMarker; // in milliseconds, default Timer delay for auto continue function
  int autoContinueMarkerIfSeeked = 0; //adjusted marker if seeked during playing
  Timer? autoContinueTimer; // timer for auto continue in play function
  final int autoContinueExecutionOffset =
      0; // ms earlier than actuall auto continue marker

// LOOPING
  bool loopStropped = false;
  Timer? loopingTimer; // timer for looping function

//METRONOME
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

// GETTERS
  Duration get currentPosition => _currentPosition;
  Duration get duration => _duration;
  int get continueGuardTimer => _duration.inMilliseconds - autoContinueOffset;
  bool get isPlaying => _isPlaying;
  LayerPlayerPool? get currentLayerPlayerPool =>
      layerPlayersPool.globalPools.isNotEmpty &&
              layerPlayersPool.globalPools
                  .any((section) => section.sectionKey == p.currentSectionKey)
          ? layerPlayersPool.globalPools
              .firstWhere((pool) => pool.sectionKey == p.currentSectionKey)
          : null;
  PlayerPool? get currentPlayerPool {
    try {
      return playerPool
          .firstWhere((pool) => pool.sectionKey == p.currentSectionKey);
    } catch (e) {
      return null;
    }
  }

  AudioSource? get currentAudioSource => currentPlayerPool?.audioSource;

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

  // SETTERS
  set duration(Duration value) {
    _duration = value;
    notifyListeners();
  }

  set currentPosition(Duration value) {
    _currentPosition = value;
    notifyListeners();
  }

  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

// INIT METHODS
  Future<void> initPlayer() async {
    if (!player.isInitialized) {
      !kIsWeb
          ? await player.init(bufferSize: 256, sampleRate: 48000)
          : await player.init(bufferSize: 1024);
    }
    player.setVisualizationEnabled(true);
    player.setFftSmoothing(0.93);
    setGlobalVolume(globalVolume);
  }

  void getGlobalVolume() {
    if (player.isInitialized) {
      globalVolume = player.getGlobalVolume();
      notifyListeners();
    }
  }

  void setGlobalVolume(double value) {
    globalVolume = value;
    notifyListeners();
    if (player.isInitialized) {
      !kIsWeb
          ? player.setGlobalVolume(globalVolume * volumeMultiplier)
          : player.setGlobalVolume(globalVolume);
    }
  }

  void setMainPlayerVolume(double value) {
    playerVolume = value;
    notifyListeners();
  }

  void setGlobalLayerVolume(double value, String layer) {
    layerPlayersPool.setGlobalLayerVolume(value, layer);
    // log('setGlobalLayerVolume: $value, $layer');
    if (isPlaying && currentLayerPlayerPool != null) {
      layerPlayersPool.setIndividualLayerVolume(
          currentLayerPlayerPool!, layer, value);
    }
    notifyListeners();
  }

  void resetPlayers() async {
    if (player.isInitialized) await player.disposeAllSources();
    playerPool.clear();
    layerPlayersPool.resetAll();
    activeHandle = null;
    playerVolume = 1;
    _isPlaying = false;
    autoContinueMarker = null;
    autoContinueTimer?.cancel();
    notifyListeners();
  }

//HELPERS
  String getAudioFileNAme(String audioUrl) {
    return audioUrl.split('/').last;
  }

  String getAudioUrl(Section section) {
    return section.fileList[getTempoIndex(section)];
  }

  int getTempoIndex(Section section) {
    return section.userTempo != null
        ? section.tempoRange.indexOf(section.userTempo!)
        : section.tempoRange.indexOf(section.defaultTempo);
  }

  void getDuration() {
    if (playerPool.isNotEmpty && currentAudioSource != null) {
      duration = player.getLength(currentAudioSource!);
    }
  }

// PLAYBACK

  Future<void> playSection(Section section) async {
    await initPlayer();
    await player.disposeAllSources();

    final audioUrl = getAudioUrl(section);
    final audioFileName = getAudioFileNAme(audioUrl);
    final file =
        await pc.readAudioFile(section.scoreId, audioFileName, audioUrl);
    if (file.bytes.isNotEmpty) {
      // setMessage('audioSource loading');

      final AudioSource audioSource = await player.loadFile(file.path);
      // setMessage('audioSource loaded, $audioSource');
      // playerAudioSources.add(PlayerAudioSource(audioSource, section.key));
      activeHandle = await player.play(audioSource);
      isPlaying = true;
      notifyListeners();
    } else {
      final audioSource = await player.loadUrl(audioUrl);
      activeHandle = await player.play(audioSource);
      isPlaying = true;
      notifyListeners();
    }
  }

  Future<void> play() async {
    ticker.stop();
    currentPosition = Duration.zero;
    notifyListeners();
    getDuration();
    if (!layersEnabled) {
      setGlobalVolume(globalVolume);
    }

    if (p.currentSection?.layers != null && p.layersHasBeenEnabled) {
      //check if the tempo is in layers range
      if (p.userTempoIsInLayers(p.currentTempo!, p.currentSection!)) {
        await playLayers();
        toggleMainPlayerVolume();
      }
    }

    isPlaying = true;
    await playCurrentSection();
    playerVolume =
        layersEnabled ? playerVolume : (p.currentSection?.sectionVolume ?? 1);
    player.setVolume(activeHandle!, playerVolume);
    startMetronome();
    handleStartPlayback();
    p.initImagesOrder();
    p.setAdjustedMarkerPosition();
    p.imageProgress = true;
    notifyListeners();

    if (autoContinueMarker != null && !p.isLoopingActive) {
      autoContinueTimer = Timer(
          Duration(
              milliseconds: autoContinueMarker! - autoContinueExecutionOffset),
          () => handlePlayNextSection());
      //Timer will be cancelled on stop or seek
    }

    //swap images to the next one in 5000ms
    if (!p.currentSection!.looped) {
      Future.delayed(Duration(milliseconds: p.autoContinueOffset),
          () => isPlaying ? p.swapImages() : null);
    }
  }

  void pause() {
    log('pausing');
    player.pauseSwitch(activeHandle!);
    isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    if (_currentPosition.inMilliseconds > 0) {
      isPlaying = true;
      notifyListeners();
      return;
    } else {
      play();
    }
  }

  void pauseOrResume() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  Future<void> stop() async {
    if (activeHandle != null) {
      await player.stop(activeHandle!);
    }
    await stopLayers();
    p.autoContinueTimer?.cancel();
    p.loopingTimer?.cancel();
    ticker.stop();
    ticker.dispose();
    currentPosition = Duration.zero;
    p.stopMetronome();
    p.initImagesOrder();
    p.imageProgress = false;
    isPlaying = false;
    p.loopStropped = true;
    notifyListeners();
  }

  Future<void> skip() async {
    if (activeHandle != null) {
      await player.stop(activeHandle!);
    }
    await stopLayers();
    p.autoContinueTimer?.cancel();
    ticker.stop();
    ticker.dispose();
    currentPosition = Duration.zero;
    p.stopMetronome();
    p.initImagesOrder();
    p.imageProgress = false;
    notifyListeners();
  }

  Future<void> playSelectedSection(String sectionKey) async {
    if (isPlaying) {
      await skip();
    }
    p.setCurrentSectionIndex(sectionKey);
    if (isPlaying) {
      await play();
    }
  }

  Future<void> playCurrentSection() async {
    //if section is looped and loop was stopped

    //if the next section is set to skip
    if (p.currentSection?.muted == true && !p.performanceMode) {
      playNextSection();
      log('skipping muted section');
      return;
    }
    activeHandle = await player.play(currentAudioSource!);

    if (p.isLoopingActive && p.loopStropped) {
      loopStropped = false;
    }
    //if section is looped, play it again
    if (!p.loopStropped && p.currentSection?.looped == true) {
      loopingTimer = Timer(
          Duration(milliseconds: duration.inMilliseconds),
          () => !p.performanceMode && p.currentSection!.looped
              ? isPlaying
                  ? play()
                  : null
              : null);
    }
    log('player volume: ${player.getVolume(activeHandle!)}');

    isPlaying = true;
    notifyListeners();
  }

  Future<void> playPreviousSection() async {
    p.decSectionIndex();
    await play();
    p.setAdjustedMarkerPosition();
  }

  Future<void> playNextSection() async {
    p.incSectionIndex();
    await play();
  }

  Future<void> skipToNextSection() async {
    if (p.currentSectionIndex < p.playlist.length - 1) {
      if (isPlaying) {
        await skip();
        await playNextSection();
      } else {
        p.incSectionIndex();
      }
      p.setAdjustedMarkerPosition();
    }
  }

  Future<void> skipToPreviousSection() async {
    if (p.currentSectionIndex > 0) {
      if (isPlaying) {
        await skip();
        await playPreviousSection();
      } else {
        p.decSectionIndex();
      }
      p.setAdjustedMarkerPosition();
    }
  }

  void setDoublePressGuard() {
    doublePressGuard = currentPosition.inMilliseconds > 0 &&
        currentPosition.inMilliseconds < continueGuardTimer;
    notifyListeners();
  }

  void getCurrentPosition() {
    if (activeHandle != null) {
      currentPosition = player.getPosition(activeHandle!);
      setDoublePressGuard();
      notifyListeners();
    }
  }

  void handlePlaybackAndMetronome() {
    getCurrentPosition();
    if (isStarted && currentPlaylistDurationBeats.isNotEmpty) {
      setCurrentBeat();
    }
  }

  void handleStartPlayback() {
    ticker = Ticker((elapsed) {
      if (isPlaying) {
        handlePlaybackAndMetronome();
        handleStop();
      }
    });
    ticker.start();
  }

  void handleLooping(Duration position) {
    loopingTimer?.cancel();

    if (p.isLoopingActive) {
      loopingTimer = Timer(
        Duration(
            milliseconds: duration.inMilliseconds - position.inMilliseconds),
        () {
          playCurrentSection();
        },
      );
    }
  }

  void handlePlayNextSection() {
    //only when autoContinue switch in section is on
    if (p.currentSection!.autoContinue == true) {
      log('currentPosition: ${currentPosition.inMilliseconds.toString()}, autoContinueMarker: ${p.autoContinueMarker.toString()}');
      ticker.stop();
      ticker.dispose();
      stopMetronome();
      playNextSection();
    }
  }

  void handleNextSectionIfSeeked(Duration position) {
    autoContinueTimer?.cancel();

    //if seeked and the position is less than current autocontinue marker
    if (position.inMilliseconds < autoContinueMarker!) {
      autoContinueMarkerIfSeeked = autoContinueMarker! -
          position.inMilliseconds -
          autoContinueExecutionOffset;
      log('autoContinueMarkerIfSeeked: ${autoContinueMarkerIfSeeked.toString()}');
      autoContinueTimer =
          Timer(Duration(milliseconds: autoContinueMarkerIfSeeked), () {
        //Timer will be cancelled on stop
        handlePlayNextSection();
      });
    }
  }

  Future<void> seek(Duration position) async {
    player.seek(activeHandle!, position);
    if (currentLayerPlayerPool?.activeLayerHandles != null) {
      currentLayerPlayerPool?.seek(position);
    }

    //case when section autocontinues
    if (autoContinueMarker != null && !p.isLoopingActive) {
      handleNextSectionIfSeeked(position);
    } else {
      handleLooping(position);
    }
  }

  void handleStop() {
    if (p.currentSectionIndex == p.playlist.length - 1 &&
        _currentPosition.inMilliseconds >= (duration.inMilliseconds - 100) &&
        isPlaying) {
      log('handleStop: ${_currentPosition.inMilliseconds.toString()}');
      stop();
    }
  }

//LAYERS
  Future<void> playLayers() async {
    log('play layers, ');

    if (currentLayerPlayerPool != null) {
      await Future.forEach(currentLayerPlayerPool!.players, (pool) async {
        pool.playerVolume = layerPlayersPool.globalLayers
            .firstWhere((p) => p.layerName == pool.layer)
            .layerVolume;
        pool.activeHandle = await player.play(pool.audioSource);
        layersEnabled
            ? player.setVolume(pool.activeHandle!, pool.playerVolume!)
            : player.setVolume(pool.activeHandle!, 0);
      });
    }
  }

  Future<void> stopLayers() async {
    final p = currentLayerPlayerPool;
    if (p != null && p.activeLayerHandles.isNotEmpty) {
      await Future.forEach(p.activeLayerHandles, (handle) async {
        await player.stop(handle);
        log('stop layers: $handle');
      });
    }
  }

  void toggleMainPlayerVolume() {
    //if layers enabled, set main player volume to 0, and set global layer volume to 1
    if (layersEnabled) {
      playerVolume = 0;
      notifyListeners();
      if (isPlaying) toggleActiveLayers();
    } else {
      //if layers disabled, set main player volume to 1, and set global layer volume to 0
      playerVolume = 1;
      notifyListeners();
      if (isPlaying) toggleActiveLayers();
    }
  }

  void toggleActiveLayers() {
    //set main player active and turn off layers
    if (!layersEnabled) {
      //main player volume to mainPlayerVolume(1)
      player.setVolume(activeHandle!, playerVolume);
      //turn off layers, set layer players volume to 0
      if (currentLayerPlayerPool?.activeLayerHandles != null) {
        for (final SoundHandle handle
            in currentLayerPlayerPool!.activeLayerHandles) {
          player.setVolume(handle, 0);
        }
      }
    } else {
      //main player volume to 0
      player.setVolume(activeHandle!, playerVolume);

      if (currentLayerPlayerPool?.activeLayerHandles != null) {
        //set layer players volume to layerPlayersPool.globalLayers
        for (Layer layer in layerPlayersPool.globalLayers) {
          layerPlayersPool.setIndividualLayerVolume(
              currentLayerPlayerPool!, layer.layerName, layer.layerVolume);
        }
      }
    }
  }

//METRONOME
  void setCurrentBeat() {
    if (currentBeatIndex < currentPlaylistDurationBeats.length - 1) {
      final index = currentClickData!.clickData.indexWhere((click) =>
          click.time / p.tempoDiff >= currentPosition.inMilliseconds);
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
        ? metronomeBellHandle = await player.play(metronomeBell!)
        : metronomeHandle = await player.play(metronomeClick!);

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
    if (metronomeHandle != null) {
      player.setVolume(metronomeHandle!, metronomeVolume);
    }
    if (metronomeBellHandle != null) {
      player.setVolume(metronomeBellHandle!, metronomeVolume);
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

    if (metronomeHandle != null) {
      player.setVolume(
          metronomeHandle!, metronomeVolume * metronomeAttenuation);
    }
    if (metronomeBellHandle != null) {
      player.setVolume(
          metronomeBellHandle!, metronomeVolume * metronomeAttenuation);
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
