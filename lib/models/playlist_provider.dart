import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';

final persistentController = PersistentDataController();

class SessionMovement {
  final String movementKey;
  final String title;
  final int index;
  final int? renderTail;

  SessionMovement(
    this.movementKey,
    this.title,
    this.index,
    this.renderTail,
  );
}

class SectionClickData {
  final String sectionKey;
  List<ClickData> clickData;

  SectionClickData(this.sectionKey, this.clickData);
}

class PlaylistDuration {
  final String sectionKey;
  List<int> beatLengths;

  PlaylistDuration({required this.sectionKey, required this.beatLengths});
}

class PlayerPool {
  final int sectionIndex;
  AudioSource audioSource;

  PlayerPool({required this.sectionIndex, required this.audioSource});
}

class PlaylistProvider extends ChangeNotifier {
  List<Section> playlist = [];
  List<SessionMovement> sessionMovements = [];
  Score? sessionScore;
  Movement? movementToAdd;
  SessionMovement? currentMovement;
  int currentMovementIndex = 0;
  int _currentSectionIndex = 0;
  String? currentMovementKey;
  String? currentSectionKey;
  File? currentSectionImage;
  File? nextSectionImage;
  bool imagesSwapped = false;
  bool imageProgress = false;

  int filesLoaded = 0;
  bool isLoading = false;
  bool _isPlaying = false;
  bool _autoStart = false;

  //AUTO CONTINUE
  int autoContinueOffset = 5000;
  late Duration _autoContinueAt;
  bool doublePressGuard =
      true; // avoid pressing pedal twice by mistake and earlier than needed
  bool showPrompt = false;
  double adjustedAutoContinuePosition = 0; // 0 - 100, percentage
  final int autoContinueExecutionOffset =
      46; // ms earlier than actuall auto continue marker
  double guardPosition = 0; // 0 - 100, percentage
  int?
      autoContinueMarker; // in milliseconds, default Timer delay for auto continue function
  int autoContinueMarkerIfSeeked = 0; //adjusted marker if seeked during playing
  Timer? autoContinueTimer; // timer for auto continue in play function

  // AUDIO PLAYERS
  final player = SoLoud.instance;
  SoundHandle? activeHandle;
  SoundHandle? passiveHandle;
  final playerPool = <PlayerPool>[];
  bool jumped = false;
  Ticker ticker = Ticker((elapsed) {});

// Durations
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  Stream<int> position = Stream<int>.value(0);
  StreamSubscription? positionSub;

  //METRONOME
  final List<SectionClickData> playlistClickData = [];
  ClickData currentBeat = ClickData(time: 0, beat: 0);
  int currentBeatIndex = 0;
  int beatLength = 0;
  final List<PlaylistDuration> currentPlaylistDurations = [];
  bool isLeft = true;
  bool isStarted = false;
  Timer? metronomeTimer;
  int lastUsedTempo = 0;
  late int? currentTempo =
      currentSection?.userTempo ?? currentSection?.defaultTempo;

//GETTERS
  int get currentSectionIndex => _currentSectionIndex;
  Section? get currentSection => playlist.isNotEmpty
      ? playlist
          .firstWhere((section) => section.sectionIndex == _currentSectionIndex)
      : null;
  Section? get nextSection =>
      playlist.isNotEmpty && _currentSectionIndex < playlist.length - 1
          ? playlist[_currentSectionIndex + 1]
          : null;
  String get sessionComposer => sessionScore?.composer ?? '';

  List<Section> get currentMovementSections => playlist
      .where((element) =>
          element.movementKey == currentMovementKey &&
          element.scoreId == sessionScore?.id)
      .toList();

  Duration get currentPosition => _currentPosition;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get autoStart => _autoStart;
  Duration get autoContinueAt => _autoContinueAt;
  ClickData? get currentBeatData =>
      currentClickData?.clickData[currentBeatIndex];
  bool get filesAreLoaded => filesLoaded == playerPool.length;
  SectionClickData? get currentClickData => playlistClickData.isNotEmpty
      ? playlistClickData.firstWhere(
          (click) => click.sectionKey == playlist[_currentSectionIndex].key)
      : null;
  PlaylistDuration? get currentPlaylistDuration => currentPlaylistDurations
          .isNotEmpty
      ? currentPlaylistDurations.firstWhere(
          (element) => element.sectionKey == playlist[currentSectionIndex].key)
      : null;
  List<int> get currentPlaylistDurationBeats =>
      currentPlaylistDuration?.beatLengths ?? [];
  bool get isFirstBeat => currentBeatData?.beat == 1;
  int get continueGuardTimer => duration.inMilliseconds - autoContinueOffset;
  Duration? get defaultAutoContinueMarker => currentSection?.autoContinueMarker;
  double? get defaultSectionLength => currentSection?.defaultSectionLength;
  bool get isDefaultTempo => currentSection?.defaultTempo == currentTempo;
  double get tempoDiff => setTempoDiff();
  int get tailDuration => currentMovement?.renderTail ?? 0;

  set duration(Duration value) {
    _duration = value;
    notifyListeners();
  }

  set currentPosition(Duration value) {
    _currentPosition = value;
    notifyListeners();
  }

  set currentSectionIndex(int index) {
    _currentSectionIndex = index;
    setDefaultTempos();
    setCurrentSectionImage();

    if (lastUsedTempo != currentTempo) {}
    currentPosition = Duration.zero;
    setAdjustedMarkerPosition();
    duration = player.getLength(playerPool
        .firstWhere((pool) => pool.sectionIndex == index)
        .audioSource);
    notifyListeners();
  }

  set isPlaying(bool value) {
    _isPlaying = value;
    notifyListeners();
  }

  set autoStart(bool value) {
    _autoStart = value;
    notifyListeners();
  }

  set autoContinueAt(Duration value) {
    _autoContinueAt = value;
    notifyListeners();
  }

  set setCurrentBeatIndex(int index) {
    currentBeatIndex = index;
    notifyListeners();
  }

  void resetPlayers() {
    playerPool.clear();
    _currentSectionIndex = 0;
    _isPlaying = false;
    _autoStart = false;
    _autoContinueAt = Duration.zero;
    autoContinueMarker = null;
    autoContinueTimer?.cancel();
    filesLoaded = 0;
    currentPlaylistDurations.clear();
    notifyListeners();
  }

  Future<void> setPlayerPool() async {
    final loadAudioFiles = <Future>[];
    final audioUrls = <Map<int, dynamic>>[];
    final audioFilesUrls = <Map<int, dynamic>>[];
    await player.init();

    for (Section section in playlist) {
      //get tempo
      final tempoIndex = section.userTempo != null
          ? section.tempoRange.indexOf(section.userTempo!)
          : section.tempoRange.indexOf(section.defaultTempo);
      //get source url
      final audioUrl = section.fileList[tempoIndex];
      audioUrls.add({section.sectionIndex: audioUrl});
    }

    Future<void> loadFile(int index, String audioUrl) async {
      final scoreId = playlist[0].scoreId;
      final String audioFileName = audioUrl.split('/').last;
      final file = await persistentController.readAudioFile(
          scoreId, audioFileName, audioUrl);
      audioFilesUrls.add({index: file.path});
    }

    for (final audioUrl in audioUrls) {
      loadAudioFiles.add(loadFile(audioUrl.keys.first, audioUrl.values.first));
    }

    await Future.wait(loadAudioFiles);

    audioFilesUrls.sort((a, b) => a.keys.first.compareTo(b.keys.first));

    for (final audioFileUrl in audioFilesUrls) {
      try {
        // log(audioFileUrl.values.first);
        final sectionIndex = audioFileUrl.keys.first;
        final audioSource = await player.loadFile(audioFileUrl.values.first);
        playerPool.add(
            PlayerPool(sectionIndex: sectionIndex, audioSource: audioSource));
        filesLoaded++;
        notifyListeners();
      } catch (e) {
        log(e.toString());
      }
    }
  }

  void setDefaultTempos() {
    lastUsedTempo = currentSection?.defaultTempo ?? 0;
    currentTempo =
        currentSection?.userTempo ?? currentSection?.defaultTempo ?? 0;
  }

  //create array of AudioPlayers for all songs in playlist
  void initSessionPlayers(int index) async {
    isLoading = true;
    resetPlayers();
    await setPlayerPool();

    //set current section image and duration if not empty
    if (playerPool.isNotEmpty &&
        _currentSectionIndex <= playerPool.length - 1) {
      setCurrentSectionImage();
      getDuration();
    }

    setDefaultTempos();
    setAdjustedMarkerPosition();
    isLoading = false;
    notifyListeners();
  }

  void orderPlaylistAndPool() {
    playlist.sort((a, b) => a.sectionIndex.compareTo(b.sectionIndex));
    playerPool.sort((a, b) => a.sectionIndex.compareTo(b.sectionIndex));
  }

  void getDuration() {
    if (playerPool.isNotEmpty && currentAudioSource() != null) {
      duration = player.getLength(currentAudioSource()!);
    }
  }

  Future<void> patchPool(int tempo) async {
    final currentPool = currentPlayerPool();
    final int? tempoindex = currentSection?.tempoRange.indexOf(tempo);
    if (tempoindex != null) {
      final audioUrl = currentSection?.fileList[tempoindex];
      final audioFileName = audioUrl?.split('/').last;
      // log(audioFileName.toString());
      final file = await persistentController.readAudioFile(
          currentSection!.scoreId, audioFileName!, audioUrl!);
      if (file.bytes.isNotEmpty && currentPool != null) {
        currentPool.audioSource = await player.loadFile(file.path);
      } else {
        currentPool?.audioSource = await player.loadUrl(audioUrl);
      }
      getDuration();
      // adjust the timing for autoContinue
      setAdjustedMarkerPosition();
      notifyListeners();
    }
  }

  PlayerPool? currentPlayerPool() {
    // log(playerPool.length.toString());
    return playerPool
        .firstWhere((pool) => pool.sectionIndex == _currentSectionIndex);
  }

  AudioSource? currentAudioSource() {
    return currentPlayerPool()?.audioSource;
  }

  Future<void> playCurrentSection() async {
    activeHandle = await player.play(currentAudioSource()!);
  }

  void getCurrentPosition() {
    currentPosition = player.getPosition(activeHandle!);
    doublePressGuard = currentPosition.inMilliseconds > 0 &&
        currentPosition.inMilliseconds < continueGuardTimer;
    notifyListeners();
  }

  void getPositionStream() {
    position = Stream<int>.periodic(const Duration(milliseconds: 1), (pos) {
      return player.getPosition(activeHandle!).inMilliseconds;
    });
  }

  void handleAutoContinue(Duration position) {
    if (position.inMilliseconds >=
            autoContinueMarker! - autoContinueExecutionOffset &&
        position.inMilliseconds - 20 < autoContinueMarker! + 20) {
      jumped = true;
      ticker.stop();
      ticker.dispose();
      stopMetronome();
      playNextSection();
      return;
    }
  }

  void handlePlaybackAndMetronome() {
    getCurrentPosition();
    if (isStarted && currentPlaylistDurationBeats.isNotEmpty) {
      setCurrentBeat();
    }

// previous implementation of autocontinue, laggy and not so reliable
    // if (autoContinueMarker != null &&
    //     !jumped &&
    //     currentPosition.inMilliseconds >
    //         autoContinueMarker! - autoContinueExecutionOffset) {
    //   log('current position: ${currentPosition.inMilliseconds.toString()}, autoContinueMarker: ${autoContinueMarker.toString()}');
    //   handleAutoContinue(currentPosition);
    // }
  }

  //isolate test
  void handleStartPlayback() {
    ticker = Ticker((elapsed) {
      if (isPlaying) {
        handlePlaybackAndMetronome();
        handleStop();
      }
    });
    ticker.start();
  }

  void play() async {
    ticker.stop();
    jumped = false;
    currentPosition = Duration.zero;
    notifyListeners();
    getDuration();
    await playCurrentSection();
    isPlaying = true;
    getPositionStream(); //test position Stream
    startMetronome();
    handleStartPlayback();
    initImagesOrder();
    setAdjustedMarkerPosition();
    imageProgress = true;
    notifyListeners();

    //simplified implementation of autocontinue
    if (autoContinueMarker != null) {
      autoContinueTimer = Timer(
          Duration(
              milliseconds: autoContinueMarker! - autoContinueExecutionOffset),
          () {
        //Timer will be cancelled on stop or seek
        handlePlayNextSection();
      });
    }
    Future.delayed(Duration(milliseconds: autoContinueOffset),
        () => isPlaying ? swapImages() : null);
    positionSub = position.listen((position) {});
  }

  void handlePlayNextSection() {
    jumped = true;
    log('currentPosition: ${currentPosition.inMilliseconds.toString()}, autoContinueMarker: ${autoContinueMarker.toString()}');
    ticker.stop();
    ticker.dispose();
    stopMetronome();
    playNextSection();
  }

// if marker is 50000, and seeked position is 30000, 50000 - 30000 = 20000 (autoContinueMarkerIfSeeked)
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

  void seek(Duration position) async {
    player.seek(activeHandle!, position);
    if (autoContinueMarker != null) {
      handleNextSectionIfSeeked(position);
    }
  }

  void handleStop() {
    if (_currentSectionIndex == playlist.length - 1 &&
        _currentPosition.inMilliseconds >= (duration.inMilliseconds - 100) &&
        isPlaying) {
      log('handleStop: ${_currentPosition.inMilliseconds.toString()}');
      stop();
    }
  }

  void setAdjustedMarkerPosition() {
    if (defaultAutoContinueMarker != null) {
      autoContinueMarker = adjustedAutoContinueMarker()?.inMilliseconds;
      setGuardAndMarker();
    } else {
      autoContinueMarker = null;
      guardPosition = setGuardPosition();
    }
    // log('setAdjustedMarkerPosition: ${autoContinueMarker.toString()}');
  }

  void setGuardAndMarker() {
    adjustedAutoContinuePosition = adjustedAutoContinueRatio();
    guardPosition = setGuardPosition();
  }

  void setCurrentBeat() {
    if (currentBeatIndex < currentPlaylistDurationBeats.length - 1) {
      final index = currentClickData!.clickData.indexWhere(
          (click) => click.time / tempoDiff >= currentPosition.inMilliseconds);
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
      }
    } else {
      stopMetronome();
    }
  }

  void setBeatLength() {
    if (currentPlaylistDurationBeats.isNotEmpty) {
      beatLength =
          (currentPlaylistDurationBeats[currentBeatIndex] / tempoDiff).round();
      notifyListeners();
    }
  }

  void startMetronome() {
    metronomeTimer?.cancel();
    currentBeatIndex = 0;
    isLeft = !isLeft;
    if (currentPlaylistDurationBeats.isNotEmpty) setBeatLength();
    isStarted = true;
    notifyListeners();
  }

  void playMetronome() {
    if (currentBeatIndex < currentPlaylistDurationBeats.length - 1) {
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

// pause a song
  void pause() {
    log('pausing');
    player.pauseSwitch(activeHandle!);
    isPlaying = false;
    notifyListeners();
  }

// resume playing
  void resume() async {
    if (_currentPosition.inMilliseconds > 0) {
      isPlaying = true;
      notifyListeners();
      return;
    } else {
      play();
    }
  }

// pause or resume
  void pauseOrResume() {
    if (_isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  void stop() async {
    await player.stop(activeHandle!);
    autoContinueTimer?.cancel();
    ticker.stop();
    ticker.dispose();
    currentPosition = Duration.zero;
    stopMetronome();
    initImagesOrder();
    imageProgress = false;
    isPlaying = false;
    positionSub?.cancel();
    notifyListeners();
  }

//play next song
  void playPreviousSection() {
    _currentSectionIndex = (_currentSectionIndex - 1) % playlist.length;
    setCurrentSectionAndMovementKey();
    jumped = false;
    play();
    // setCurrentSectionImage();
    setAdjustedMarkerPosition();
  }

// play previous song
  void playNextSection() async {
    if (_currentSectionIndex < playlist.length - 1) {
      _currentSectionIndex++;
      setCurrentSectionAndMovementKey();
      jumped = false;
      play();
    }
    // setCurrentSectionImage();
  }

  void skipToNextSection() {
    if (_currentSectionIndex < playlist.length - 1) {
      if (isPlaying) {
        stop();
        playNextSection();
      } else {
        _currentSectionIndex++;
        setCurrentSectionAndMovementKey();
      }
      // setCurrentSectionImage();s
      setAdjustedMarkerPosition();
    }
  }

  void skipToPreviousSection() {
    if (_currentSectionIndex > 0) {
      if (isPlaying) {
        stop();
        playPreviousSection();
      } else {
        _currentSectionIndex--;
        setCurrentSectionAndMovementKey();
      }
      // setCurrentSectionImage();
      setAdjustedMarkerPosition();
    }
  }

  double autoContinueRatio(Duration marker) {
    if (currentSection?.defaultSectionLength != null) {
      final int sectionLength = duration.inMilliseconds;
      return marker.inMilliseconds / sectionLength * 100;
    } else {
      return 0;
    }
  }

  Duration calculateMarkerPosition(
      Duration originalSectionDuration,
      Duration currentAudioDuration,
      int tailDuration,
      Duration originalMarkerPosition) {
    // Calculate the original active section duration in milliseconds
    final int originalActiveDuration =
        originalSectionDuration.inMilliseconds - (tailDuration * 1000);

    // Validate the original marker position to ensure it's within the original active section
    if (originalMarkerPosition.inMilliseconds > originalActiveDuration) {
      return const Duration(milliseconds: 0); // Indicative of an error state.
    }

    // Calculate the new active section duration
    final int newActiveDuration =
        currentAudioDuration.inMilliseconds - (tailDuration * 1000);

    // Calculate the relative position (percentage) of the marker in the original active section
    final double originalMarkerRelativePosition =
        originalMarkerPosition.inMilliseconds / originalActiveDuration;

    // Apply the original relative position to the new active section to find the new marker position in seconds
    final int newMarkerPositionInMilliseconds =
        (originalMarkerRelativePosition * newActiveDuration).round();

    // log('newMarkerPositionInMilliseconds: $newMarkerPositionInMilliseconds');

    // Optionally, if needed, convert the new marker position back to a percentage of the new active section
    // ignore: unused_local_variable
    final double newMarkerPositionPercentage =
        (newMarkerPositionInMilliseconds / newActiveDuration) * 100;

    return Duration(
        milliseconds:
            newMarkerPositionInMilliseconds); // Or return newMarkerPositionPercentage if you prefer the percentage
  }

  Duration? adjustedAutoContinueMarker() {
    return isDefaultTempo
        ? defaultAutoContinueMarker
        : calculateMarkerPosition(
            Duration(milliseconds: (defaultSectionLength! * 1000).round()),
            duration,
            tailDuration,
            defaultAutoContinueMarker!);
  }

  double adjustedAutoContinueRatio() {
    if (defaultSectionLength != null && defaultAutoContinueMarker != null) {
      final adjustedMarker = calculateMarkerPosition(
          Duration(milliseconds: (defaultSectionLength! * 1000).round()),
          duration,
          tailDuration,
          defaultAutoContinueMarker!);

      return isDefaultTempo && defaultAutoContinueMarker != null
          ? autoContinueRatio(defaultAutoContinueMarker!)
          : autoContinueRatio(adjustedMarker);
    }

    return 0;
  }

  double setGuardPosition() {
    final int safetyTimer = duration.inMilliseconds - autoContinueOffset;
    if (duration.inMilliseconds <= 7000) {
      //percentage of 100
      return 30;
    }
    return safetyTimer / duration.inMilliseconds * 100;
  }

  Future<List<ClickData>> loadClickData(Section section) async {
    List<ClickData> clickData = await persistentController.readClickJsonFile(
        section.scoreId, section.key, section.clickDataUrl!);
    return clickData;
  }

  Future<SectionClickData> loadSectionClickData(Section section) async {
    List<ClickData> clickData = await loadClickData(section);
    SectionClickData sectionClickData =
        SectionClickData(section.key, clickData);
    return sectionClickData;
  }

  Future<void> loadPlaylistClickData(Section section) async {
    SectionClickData sectionClickData = await loadSectionClickData(section);

    void setPlaylistClickData(SectionClickData value) {
      playlistClickData.add(value);
      notifyListeners();
    }

    // set bet lengths for each clickdata
    currentPlaylistDurations
        .add(PlaylistDuration(sectionKey: section.key, beatLengths: []));

    for (int i = 0; i < sectionClickData.clickData.length - 1; i++) {
      final beatLength = sectionClickData.clickData[i + 1].time -
          sectionClickData.clickData[i].time;
      currentPlaylistDurations
          .firstWhere((element) => element.sectionKey == section.key)
          .beatLengths
          .add(beatLength);
    }

    setPlaylistClickData(sectionClickData);
  }

  void loadClickFiles(List<Section> sections) async {
    playlistClickData.clear();
    final loadClickTasks = <Future>[];

    for (Section section in sections) {
      if (section.metronomeAvailable == true) {
        loadClickTasks.add(loadPlaylistClickData(section));
      }
    }

    await Future.wait(loadClickTasks);
  }

  void setUserTempo(int tempo) async {
    currentTempo = tempo;
    if (currentTempo != currentSection?.userTempo ||
        currentTempo != currentSection?.defaultTempo) {
      await patchPool(tempo);
      currentSection?.userTempo = tempo;
    }
    log('tempoDiff: ${tempoDiff.toString()}');
    log('lastUsedTempo: ${lastUsedTempo.toString()}');
    log('current tempo: $currentTempo');

    lastUsedTempo = tempo;
    notifyListeners();
  }

  double setTempoDiff() {
    return currentTempo != null && currentSection != null
        ? currentTempo! / currentSection!.defaultTempo
        : 1;
  }

  bool containsMovement(String key) {
    return sessionMovements.any((element) => element.movementKey == key);
  }

  void addMovement(Score score, Movement movement) {
    movementToAdd = movement;
    //check if sections from other concerto are already in session
    if (playlist.any((element) => element.scoreId != score.id)) {
      showPrompt = true;
      notifyListeners();
    } else {
      for (final section in movement.setupSections) {
        //check if section already exists in session
        if (playlist.any((element) => element.key == section.key)) {
          continue;
        } else {
          playlist.add(section);
          // section.sectionIndex = playlist.indexOf(section);
          sessionScore = score;
        }
      }
      // playlist.sort((a, b) => a.movementIndex.compareTo(b.movementIndex));
      playlist.sort((a, b) => a.sectionIndex.compareTo(b.sectionIndex));

      sessionMovements.add(SessionMovement(
          movement.key, movement.title, movement.index, movement.renderTail));
      sessionMovements.sort((a, b) => a.index.compareTo(b.index));
      for (final element in playlist) {
        element.sectionIndex = playlist.indexOf(element);
        // log(element.movementIndex.toString());
      }

      notifyListeners();
    }
  }

  void closePrompt() {
    showPrompt = false;
    notifyListeners();
  }

  void removeMovement(Movement movement) {
    for (final section in movement.setupSections) {
      playlist.removeWhere((element) => element.key == section.key);
    }

    sessionMovements.removeWhere(
        (SessionMovement item) => item.movementKey == movement.key);
    sessionMovements.sort((a, b) => a.index.compareTo(b.index));
    if (playlist.isEmpty) {
      sessionScore = null;
    }
    notifyListeners();
  }

  void setMovementIndexByKey(String movementKey) {
    currentMovementKey = movementKey;
    _currentSectionIndex = playlist.indexWhere(
      (element) => element.movementKey == movementKey,
    );
    currentSectionKey = playlist[_currentSectionIndex].key;
    currentMovement = sessionMovements
        .firstWhere((element) => element.movementKey == currentMovementKey);
    currentMovementIndex = sessionMovements
        .indexWhere((element) => element.movementKey == currentMovementKey);
    setCurrentPlaylistTempo();
    setCurrentSectionImage();
  }

  void setCurrentSectionByKey(String sectionKey) {
    _currentSectionIndex = playlist.indexWhere(
      (element) => element.key == sectionKey,
    );
    currentMovementIndex = playlist[_currentSectionIndex].movementIndex;
    setCurrentSectionAndMovementKey();
    currentMovement = sessionMovements.firstWhere(
      (element) => element.movementKey == currentMovementKey,
    );
    setCurrentSectionImage();
  }

  void setCurrentSectionAndMovementKey() {
    currentSectionKey = playlist[_currentSectionIndex].key;
    currentMovementKey = playlist[_currentSectionIndex].movementKey;
    setCurrentPlaylistTempo();
  }

  void setCurrentPlaylistTempo() {
    currentTempo = currentSection?.userTempo ?? currentSection?.defaultTempo;
    getDuration();
    setGuardAndMarker();
  }

  void clearSession() {
    playlist.clear();
    sessionMovements.clear();
    sessionScore = null;
    showPrompt = false;
    notifyListeners();
  }

  Future<void> setCurrentSectionImage() async {
    // currentSectionImage = null;
    if (sessionScore?.id != null && currentSection?.sectionImage != null) {
      log('currentSectionImage: ${currentSection!.sectionImage!.asset.ref}');
      currentSectionImage = await persistentController.readImageFile(
          sessionScore!.id, currentSection!.sectionImage!.asset.ref);
      notifyListeners();
    }
  }

  Future<void> setNextSectionImage() async {
    if (nextSection?.sectionImage != null) {
      nextSectionImage = await persistentController.readImageFile(
          sessionScore!.id, nextSection!.sectionImage!.asset.ref);
      notifyListeners();
    }
  }

  void swapImages() {
    if (currentSection != null && nextSection != null) {
      if (nextSectionImage != null) {
        currentSectionImage = nextSectionImage;
        nextSectionImage = null;
      }
      setImageSwapped(true);
      notifyListeners();
    }
  }

  Future<void> initImagesOrder() async {
    if (currentSection != null && nextSection != null) {
      await setCurrentSectionImage();
      await setNextSectionImage();
      setImageSwapped(false);
    }
  }

  void setImageSwapped(bool value) {
    imagesSwapped = value;
    notifyListeners();
  }
}
