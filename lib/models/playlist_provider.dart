import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final persistentController = PersistentDataController();
final p = PlaylistProvider();
final a = AudioProvider();
final m = MetronomeProvider();

class SessionMovement {
  final String movementKey;
  final String scoreId;
  final String title;
  final int index;
  final int? renderTail;

  SessionMovement(
    this.movementKey,
    this.scoreId,
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

final List<Layer> defaultMixer = [
  // Layer(layerName: 'f'),
  Layer(layerName: 'w'),
  Layer(layerName: 'b'),
  Layer(layerName: 'p'),
  Layer(layerName: 's'),
];

class PlaylistProvider extends ChangeNotifier {
  // PLAYLIST
  List<Section> playlist = [];
  List<SessionMovement> sessionMovements = [];
  Score? sessionScore;
  Movement? movementToAdd;
  SessionMovement? currentMovement;
  int currentMovementIndex = 0;
  int _currentSectionIndex = 0;
  String? currentMovementKey;
  String? currentSectionKey;
  final orchestralLayers = <OrchestraLayer>[
    OrchestraLayer.flute,
    OrchestraLayer.woodwinds,
    OrchestraLayer.brass,
    OrchestraLayer.percussion,
    OrchestraLayer.strings
  ];
  bool layersEnabled = false;
  bool onePedalMode = false;
  int totalLayerFiles = 0;

  //IMAGES
  File? currentSectionImage;
  File? nextSectionImage;
  bool imagesSwapped = false;
  bool imageProgress = false;

  // LOADING
  int filesLoaded = 0;
  int layerFilesLoaded = 0;
  bool isLoading = false;
  bool layerFilesLoading = false;

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
  bool _isPlaying = false;
  bool jumped = false;
  Ticker ticker = Ticker((elapsed) {});
  double globalVolume = 1;
  double playerVolume = 1;
  final GlobalLayerPlayerPool layerPlayersPool = GlobalLayerPlayerPool(
    globalLayers: [],
  );

// DURATIONS
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
  //PLAYLIST
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
  Duration get autoContinueAt => _autoContinueAt;
  bool get autoContinueEnabled => currentSection?.autoContinue ?? false;
  bool get filesAreLoaded => filesLoaded == playerPool.length;
  int get continueGuardTimer => duration.inMilliseconds - autoContinueOffset;
  Duration? get defaultAutoContinueMarker => currentSection?.autoContinueMarker;
  double? get defaultSectionLength => currentSection?.defaultSectionLength;
  bool get isDefaultTempo => currentSection?.defaultTempo == currentTempo;
  double get tempoDiff => setTempoDiff();
  int get tailDuration => currentMovement?.renderTail ?? 0;

  Duration get currentPosition => _currentPosition;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;
  LayerPlayerPool? get currentLayerPlayerPool =>
      layerPlayersPool.globalPools.isNotEmpty &&
              layerPlayersPool.globalPools
                  .any((section) => section.sectionKey == currentSectionKey)
          ? layerPlayersPool.globalPools
              .firstWhere((pool) => pool.sectionKey == currentSectionKey)
          : null;

  ClickData? get currentBeatData => currentClickData?.clickData != null &&
          currentClickData!.clickData.isNotEmpty &&
          currentClickData?.clickData[currentBeatIndex] != null
      ? currentClickData!.clickData[currentBeatIndex]
      : null;
  ClickData? get nextBeatData => currentClickData?.clickData[currentBeatIndex];
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

  set autoContinueAt(Duration value) {
    _autoContinueAt = value;
    notifyListeners();
  }

  set setCurrentBeatIndex(int index) {
    currentBeatIndex = index;
    notifyListeners();
  }

  void setOnePedalMode(bool value) async {
    onePedalMode = value;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('onePedalMode', value);
    notifyListeners();
  }

  void getOnePedalMode() async {
    final prefs = await SharedPreferences.getInstance();
    onePedalMode = prefs.getBool('onePedalMode') ?? false;
    notifyListeners();
  }

  void resetPlayers() {
    playerPool.clear();
    layerPlayersPool.resetAll();
    activeHandle = null;
    playerVolume = 1;
    _currentSectionIndex = 0;
    _isPlaying = false;
    // _autoStart = false;
    _autoContinueAt = Duration.zero;
    autoContinueMarker = null;
    autoContinueTimer?.cancel();
    filesLoaded = 0;
    layerFilesLoaded = 0;
    totalLayerFiles = 0;
    currentPlaylistDurations.clear();
    notifyListeners();
  }

  int getTempoIndex(Section section) {
    return section.userTempo != null
        ? section.tempoRange.indexOf(section.userTempo!)
        : section.tempoRange.indexOf(section.defaultTempo);
  }

  String getAudioUrl(Section section) {
    return section.fileList[getTempoIndex(section)];
  }

  String getAudioLayerUrl(Section section, String layer) {
    String pathName =
        '$supabaseUrl${sessionScore!.slug}/${section.movementIndex}/${section.name}/STEMS/';
    String fileName =
        '${sessionScore!.pathName}_${section.movementIndex}_${section.name}';

    //reading userLayerTempo if exists, otherwise useing the default tempo
    return '$pathName/${fileName}_${section.userLayerTempo ?? section.defaultTempo}_$layer.$audioFormat';
  }

  List<SectionLayer> setLayerAudioUrls(Section section) {
    final sectionLayers = <SectionLayer>[];

    if (section.layers != null && section.layers!.isNotEmpty) {
      for (final layer in section.layers!) {
        sectionLayers.add(SectionLayer(
            layer: layer, audioUrl: getAudioLayerUrl(section, layer)));
        totalLayerFiles++;
      }
    }

    return sectionLayers;
  }

  String getAudioFileNAme(String audioUrl) {
    return audioUrl.split('/').last;
  }

  Future<void> setPlayerPool() async {
    final loadAudioFiles = <Future>[];
    final audioUrls = <AudioUrl>[];
    final audioFilesUrls = <AudioUrl>[];
    await player.init();

    for (Section section in playlist) {
      final audioUrl = getAudioUrl(section);
      audioUrls.add(AudioUrl(section.sectionIndex, section.key, audioUrl));
    }

    Future<void> loadFile(AudioUrl audioUrl) async {
      final scoreId = playlist[0].scoreId;
      final String audioFileName = getAudioFileNAme(audioUrl.url);
      final file = await persistentController.readAudioFile(
          scoreId, audioFileName, audioUrl.url);
      audioFilesUrls
          .add(AudioUrl(audioUrl.sectionIndex, audioUrl.sectionKey, file.path));
    }

    for (final audioUrl in audioUrls) {
      loadAudioFiles.add(loadFile(audioUrl));
    }

    await Future.wait(loadAudioFiles);

    audioFilesUrls.sort((a, b) => a.sectionIndex.compareTo(b.sectionIndex));

    for (final audioFileUrl in audioFilesUrls) {
      try {
        final audioSource = await player.loadFile(audioFileUrl.url);
        playerPool.add(PlayerPool(
            sectionIndex: audioFileUrl.sectionIndex,
            sectionKey: audioFileUrl.sectionKey,
            audioSource: audioSource));
        filesLoaded++;
        notifyListeners();
      } catch (e) {
        log(e.toString());
      }
    }
  }

  void setGlobalPlaylistLayers() {
    if (sessionScore != null && sessionScore!.globalLayers != null) {
      for (final layer in sessionScore!.globalLayers!) {
        layerPlayersPool.globalLayers.add(Layer(layerName: layer));
      }
    }
  }

  Future<void>? setSectionLayersPlayerPool(Section section, bool patch) async {
    final handleLoadLayerFiles =
        <Future>[]; //set of tasks running at the same time
    late MainPlayer mainPlayer;
    final layerPlayers = <LayerPlayer>[];
    final sectionLayers = <SectionLayer>[];

    //initialize player if for some reason it's not
    if (!player.isInitialized) {
      await player.init();
    }

    Future<void> setLayerPlayerPool(
        String filePath, String audioFileName, String layer) async {
      try {
        AudioSource audioSource = await player.loadFile(filePath);
        layerPlayers.add(
          LayerPlayer(
              sectionIndex: section.sectionIndex,
              sectionKey: section.key,
              audioSource: audioSource,
              layer: layer,
              player: player),
        );
        layerFilesLoaded++;
        totalLayerFiles++;
        notifyListeners();
      } catch (e) {
        log(e.toString());
      }
    }

    Future<void> setMainPlayer(String filePath) async {
      try {
        AudioSource audioSource = await player.loadFile(filePath);
        mainPlayer = MainPlayer(audioSource: audioSource, player: player);
        log('mainPlayer set');
        notifyListeners();
      } catch (e) {
        log(e.toString());
      }
    }

    Future<void> loadAudioFiles(SectionLayer sectionLayer) async {
      final String layerAudioFileName = getAudioFileNAme(sectionLayer.audioUrl);
      log('audioFileName: $layerAudioFileName, audioUrl: ${sectionLayer.audioUrl}');

      //layer file
      final layerFile = await persistentController.readAudioFile(
          sessionScore!.id, layerAudioFileName, sectionLayer.audioUrl);
      await setLayerPlayerPool(
          layerFile.path, layerAudioFileName, sectionLayer.layer);
    }

    //SET MAIN PLAYER, NOT DOING ANYTHING RIGHT NOW
    final String audioFileName = getAudioFileNAme(getAudioUrl(section));
    final file = await persistentController.readAudioFile(
        sessionScore!.id, audioFileName, getAudioUrl(section));
    await setMainPlayer(file.path);
    //

    for (final String layer in section.layers!) {
      sectionLayers.add(SectionLayer(
          layer: layer, audioUrl: getAudioLayerUrl(section, layer)));
    }

    //getting section layer audio files
    for (final sectionLayer in sectionLayers) {
      handleLoadLayerFiles.add(loadAudioFiles(sectionLayer));
    }

    await Future.wait(handleLoadLayerFiles);

    LayerPlayerPool addPlayerPool() {
      final layerPlayerPool = LayerPlayerPool(
          sectionIndex: section.sectionIndex,
          sectionKey: section.key,
          tempo: section.userLayerTempo ?? section.defaultTempo,
          layers: sectionLayers,
          mainPlayer: mainPlayer,
          players: layerPlayers);

      if (patch) {
        final index = layerPlayersPool.globalPools
            .indexWhere((p) => p.sectionKey == section.key);
        layerPlayersPool.globalPools.removeAt(index);
        layerPlayersPool.globalPools.insert(index, layerPlayerPool);
      } else {
        layerPlayersPool.globalPools.add(layerPlayerPool);
      }

      return layerPlayerPool;
    }

    addPlayerPool();
  }

  void setDefaultTempos() {
    lastUsedTempo = currentSection?.defaultTempo ?? 0;
    currentTempo =
        currentSection?.userTempo ?? currentSection?.defaultTempo ?? 0;
  }

  //create array of AudioPlayers for all sections in playlist
  void initSessionPlayers(String sectionKey) async {
    isLoading = true;
    resetPlayers();

    await setPlayerPool();
    setGlobalPlaylistLayers();
    layersEnabled = false;

    //set current section image and duration if not empty
    if (playerPool.isNotEmpty &&
        _currentSectionIndex <= playerPool.length - 1) {
      // setCurrentSectionImage();
      setCurrentSectionByKey(sectionKey);
      getDuration();
    }

    setDefaultTempos();
    setAdjustedMarkerPosition();
    getOnePedalMode();
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
      player.setGlobalVolume(globalVolume);
    }
  }

  void setPlayerVolume(double value) {
    playerVolume = value;
    notifyListeners();
  }

  void setGlobalLayerVolume(
    double value,
    String layer,
  ) {
    layerPlayersPool.setGlobalLayerVolume(value, layer);
    // log('setGlobalLayerVolume: $value, $layer');
    if (isPlaying && currentLayerPlayerPool != null) {
      layerPlayersPool.setIndividualLayerVolume(
          currentLayerPlayerPool!, layer, value);
    }
    notifyListeners();
  }

  Future<void> setLayersEnabled(bool value) async {
    layersEnabled = value;
    layerFilesLoading = true;
    notifyListeners();

    log('layerFilesLoaded: $layerFilesLoaded, totalLayerFiles: $totalLayerFiles');
    if (totalLayerFiles == 0) {
      for (Section section
          in playlist.where((section) => section.layers != null)) {
        //check if files are there already
        if (layerPlayersPool.globalPools.isNotEmpty &&
            layerPlayersPool.globalPools
                .any((element) => element.sectionKey == section.key)) {
          continue;
        } else {
          await setSectionLayersPlayerPool(section, false);

          //if tempo selected doesn't exist in tempoRange set it to userLayerTempo or default
          if (section.tempoRangeLayers != null &&
              !section.tempoRangeLayers!.contains(section.userTempo)) {
            final int index = section.tempoRange
                .indexOf(section.userLayerTempo ?? section.defaultTempo);
            await patchPoolIfNotInLayersTempoRange(index, section);
          }

          await setGlobalLayers();
        }
      }
    }
    toggleDefaultToLayerPlayerVolume(layersEnabled);

    layerFilesLoading = false;
    currentTempo =
        currentSection?.userLayerTempo ?? currentSection?.defaultTempo;
    notifyListeners();
  }

  Future<void> setGlobalLayers() async {
    final sectionPrefsList = <SectionPrefs>[];
    for (Section section
        in playlist.where((section) => section.layers != null)) {
      final prefs = await persistentController.readSectionJsonFile(
          sessionScore!.id, section.key);

      if (prefs != null) {
        sectionPrefsList.add(SectionPrefs.fromJson(prefs));
      }
    }

    if (sectionPrefsList.isNotEmpty) {
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final globalLayersExist = sectionPrefsList
          .indexWhere((pref) => pref.layers != null && pref.layers!.isNotEmpty);
      if (globalLayersExist != -1) {
        final globalLayers = sectionPrefsList[globalLayersExist].layers!;
        layerPlayersPool.setGlobalLayers(globalLayers);
      }
    }
  }

  void toggleDefaultToLayerPlayerVolume(bool value) {
    void setVolume(double volume) {
      if (isPlaying) {
        player.setVolume(activeHandle!, playerVolume);
        if (currentLayerPlayerPool?.activeLayerHandles != null) {
          for (Layer layer in layerPlayersPool.globalLayers) {
            layerPlayersPool.setGlobalLayerVolume(
                layer.volume, layer.layerName);
          }
        }
      }
    }

    if (value) {
      playerVolume = 0;
      setVolume(1);
    } else {
      playerVolume = 1;
      setVolume(0);
      activeHandle != null ? player.setVolume(activeHandle!, 1) : null;
    }
    notifyListeners();
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

  Future<void> patchPoolIfNotInLayersTempoRange(
      int index, Section section) async {
    final poolToPatch =
        playerPool.firstWhere((pool) => pool.sectionKey == section.key);

    if (index == -1) {
      final audioUrl = section.fileList[index];
      final audioFileName = audioUrl.split('/').last;
      log('patchPoolIfNotInLayersTempoRange, audioFileName: $audioFileName');
      final file = await persistentController.readAudioFile(
          currentSection!.scoreId, audioFileName, audioUrl);
      if (file.bytes.isNotEmpty) {
        poolToPatch.audioSource = await player.loadFile(file.path);
      } else {
        poolToPatch.audioSource = await player.loadUrl(audioUrl);
      }
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
    player.setVolume(activeHandle!, playerVolume);
    log('player volume: ${player.getVolume(activeHandle!)}');
    notifyListeners();
  }

  void getCurrentPosition() {
    currentPosition = player.getPosition(activeHandle!);
    doublePressGuard = currentPosition.inMilliseconds > 0 &&
        currentPosition.inMilliseconds < continueGuardTimer;
    notifyListeners();
  }

  // void getPositionStream() {
  //   if (activeHandle != null) {}
  //   position = Stream<int>.periodic(const Duration(milliseconds: 1), (pos) {
  //     return player.getPosition(activeHandle!).inMilliseconds;
  //   });
  // }

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

  Future<void> playLayers() async {
    // for (LayerPlayerPool pool in layerPlayersPool.globalPools) {
    //   pool.activeLayerHandles.clear();
    //   log('play layers, ${pool.activeLayerHandles.length.toString()}');
    // }
    log('play layers, ');

    if (currentLayerPlayerPool != null) {
      // currentLayerPlayerPool?.activeLayerHandles.clear();
      for (final pool in currentLayerPlayerPool!.players) {
        pool.playerVolume = layerPlayersPool.globalLayers
            .firstWhere((p) => p.layerName == pool.layer)
            .volume;
        pool.activeHandle = await player.play(pool.audioSource);
        player.setVolume(pool.activeHandle!, pool.playerVolume!);
      }
    }
  }

  void stopLayers() {
    // if (currentLayerPlayerPool?.activeLayerHandles != null) {
    //   for (final SoundHandle handle
    //       in currentLayerPlayerPool!.activeLayerHandles) {
    //     player.stop(handle);
    //   }
    // }
    for (LayerPlayerPool p in layerPlayersPool.globalPools) {
      if (p.activeLayerHandles.isNotEmpty) {
        for (final SoundHandle handle in p.activeLayerHandles) {
          player.stop(handle);
        }
      }
    }
    // log('stop layers: $handle');
  }

  void play() async {
    ticker.stop();
    jumped = false;
    currentPosition = Duration.zero;
    notifyListeners();
    getDuration();
    setGlobalVolume(globalVolume);

    if (currentSection?.layers != null && layersEnabled) {
      await playLayers();
      toggleDefaultToLayerPlayerVolume(true);
    } else {
      stopLayers();
      toggleDefaultToLayerPlayerVolume(false);
      // layersEnabled = false;
    }

    await playCurrentSection();
    isPlaying = true;
    // getPositionStream(); //test position Stream
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
  }

  void handlePlayNextSection() {
    //only when autoContinue switch in section is on
    if (currentSection!.autoContinue == true) {
      jumped = true;
      log('currentPosition: ${currentPosition.inMilliseconds.toString()}, autoContinueMarker: ${autoContinueMarker.toString()}');
      ticker.stop();
      ticker.dispose();
      stopMetronome();
      playNextSection();
    }
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
    if (currentLayerPlayerPool?.activeLayerHandles != null) {
      currentLayerPlayerPool!.seek(position);
    }
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
    if (defaultAutoContinueMarker != null &&
        currentSection?.autoContinue == true) {
      autoContinueMarker = adjustedAutoContinueMarker()?.inMilliseconds;
      setGuardAndMarker();
    } else {
      log('setAdjustedMarkerPosition: ${autoContinueMarker.toString()}, setGuard');
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
    if (activeHandle != null) {
      await player.stop(activeHandle!);
    }
    stopLayers();
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
    log('safetyTimer: $safetyTimer, autoContinueOffset: $autoContinueOffset');
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
      if (layersEnabled &&
          currentSection?.layers != null &&
          currentLayerPlayerPool?.tempo != tempo) {
        await setSectionLayersPlayerPool(currentSection!, true);
        currentLayerPlayerPool?.tempo = tempo;
        currentSection?.userLayerTempo = tempo;
      }
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

  void addMovement(Score score, Movement movement, String sectionKey) {
    movementToAdd = movement;
    //check if sections from other concerto are already in session
    if (sessionMovements.any((el) => el.scoreId != score.id)) {
      showPrompt = true;
      notifyListeners();
    } else {
      sessionMovements.add(SessionMovement(movement.key, score.id,
          movement.title, movement.index, movement.renderTail));
      sessionMovements.sort((a, b) => a.index.compareTo(b.index));

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

  void buildPlaylist(Score score) {
    playlist.clear();
    sessionScore = score;

//add sections from score according to sessionMovements
    for (SessionMovement sessionMovement in sessionMovements) {
      final movementKey = sessionMovement.movementKey;

      for (Section section in score.setupMovements
          .firstWhere((element) => element.key == movementKey)
          .setupSections) {
        playlist.add(section);
      }
    }

    for (Section section in playlist) {
      section.sectionIndex = playlist.indexOf(section);
      log('sectionIndex: ${section.sectionIndex.toString()}');
    }

    notifyListeners();
  }

  void setCurrentSectionByKey(String sectionKey) {
    _currentSectionIndex = playlist.indexWhere(
      (s) => s.key == sectionKey,
    );

    setCurrentSectionAndMovementKey();
    log('currentMovementKey: $currentMovementKey');
    // currentMovement = sessionMovements.firstWhere(
    //   (element) => element.movementKey == currentMovementKey,
    // );
    setCurrentSectionImage();
  }

  void setCurrentSectionAndMovementKey() {
    currentSectionKey = playlist[_currentSectionIndex].key;
    currentMovementKey = playlist[_currentSectionIndex].movementKey;
    setCurrentPlaylistTempo();
  }

  void setCurrentPlaylistTempo() {
    currentTempo = currentSection?.userTempo ?? currentSection?.defaultTempo;
    if (layersEnabled) {
      currentTempo =
          currentLayerPlayerPool?.tempo ?? currentSection?.defaultTempo;
    }
    getDuration();
    setGuardAndMarker();
  }

  bool? setCurrentSectionAutoContinue() {
    if (currentSection?.autoContinueMarker == null) {
      return null;
    } else if (currentSection!.autoContinue == true) {
      currentSection!.autoContinue = false;
    } else if (currentSection!.autoContinue == false) {
      currentSection!.autoContinue = true;
    } else {
      return null;
    }
    notifyListeners();
    final SectionPrefs sectionPrefs = constructSectionPrefs(currentSection!);
    setAdjustedMarkerPosition();

    persistentController.updateSectionPrefs(
        currentSection!.scoreId, currentSection!.key, sectionPrefs);
    return currentSection!.autoContinue;
  }

  void updateLayersPrefs() async {
    final SectionPrefs sectionPrefs = constructSectionPrefs(currentSection!);
    log('updateLayersPrefs: $sectionPrefs');
    persistentController.updateSectionPrefs(
        currentSection!.scoreId, currentSection!.key, sectionPrefs);
    notifyListeners();
  }

  SectionPrefs constructSectionPrefs(Section section) {
    final SectionPrefs sectionPrefs = SectionPrefs(
      sectionKey: section.key,
      defaultTempo: section.defaultTempo,
      userTempo: section.userTempo,
      userLayerTempo: section.userLayerTempo,
      autoContinue: section.autoContinue,
      layers: layerPlayersPool.globalLayers.isNotEmpty
          ? layerPlayersPool.globalLayers
          : null,
    );

    return sectionPrefs;
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

class AudioProvider extends ChangeNotifier {
  // AUDIO PLAYERS
  final player = SoLoud.instance;
  SoundHandle? activeHandle;
  final activeLayerHandles =
      <SoundHandle>[]; //when multiple layers are available for mixing
  SoundHandle? passiveHandle;
  final playerPool = <PlayerPool>[];
  bool jumped = false;
  Ticker ticker = Ticker((elapsed) {});
  double globalVolume = 1;
  double playerVolume = 1;
  List<double> layersVolumes = <double>[0, 0, 0, 0];
  final playerLayers = <OrchestraLayer>[
    OrchestraLayer.woodwinds,
    OrchestraLayer.brass,
    OrchestraLayer.percussion,
    OrchestraLayer.strings,
  ];
  final layerPlayerPool = <LayerPlayerPool>[];
  bool layersEnabled = false;
  bool _isPlaying = false;

// Durations
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  // Stream<int> position = Stream<int>.value(0);
  // StreamSubscription? positionSub;

// GETTERS
  Duration get currentPosition => _currentPosition;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;

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

  // METHODS
  void resetPlayers() {
    playerPool.clear();
    layerPlayerPool.clear();
    activeLayerHandles.clear();
    activeHandle = null;
    playerVolume = 1;
    layersVolumes = [0, 0, 0, 0];
    _isPlaying = false;
    notifyListeners();
  }
}

class MetronomeProvider extends ChangeNotifier {
  //PROVIDERS
  final List<SectionClickData> playlistClickData = [];
  ClickData currentBeat = ClickData(time: 0, beat: 0);
  int currentBeatIndex = 0;
  int beatLength = 0;
  final List<PlaylistDuration> currentPlaylistDurations = [];
  bool isLeft = true;
  bool isStarted = false;
  Timer? metronomeTimer;

//GETTERS
  ClickData? get currentBeatData =>
      currentClickData?.clickData[currentBeatIndex];
  SectionClickData? get currentClickData => playlistClickData.isNotEmpty
      ? playlistClickData.firstWhere(
          (click) => click.sectionKey == p.playlist[p._currentSectionIndex].key)
      : null;
}
