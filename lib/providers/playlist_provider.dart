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
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
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
  AppState? appState;

  PlaylistProvider() {
    appState = AppState.idle;
  }

  //IMAGES
  File? currentSectionImage;
  File? nextSectionImage;
  bool imagesSwapped = false;
  bool imageProgress = false;

  // LOADING
  int filesDownloaded = 0;
  int layerFilesDownloaded = 0;
  int filesLoaded = 0;
  int layerFilesLoaded = 0;
  bool filesDownloading = false;
  bool layerFilesDownloading = false;
  bool isLoading = false;
  bool layerFilesLoading = false;
  List<String> currentlyLoadedFiles = [];

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
  double globalVolume = 1.0;
  double mainPlayerVolume = 1.0;
  // double volumeMultiplier = 2.0;
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

  void setSectionSkipped(String key) {
    final Section section =
        playlist.firstWhere((element) => element.key == key);
    section.muted = !section.muted;
    log('muted: ${section.muted}');
    notifyListeners();

    final SectionPrefs sectionPrefs = constructSectionPrefs(currentSection!);

    persistentController.updateSectionPrefs(
        currentSection!.scoreId, currentSection!.key, sectionPrefs);
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
    mainPlayerVolume = 1;
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

//LAYERS
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
    // late MainPlayer mainPlayer;
    final layerPlayers = <LayerPlayer>[];
    final sectionLayers = <SectionLayer>[];

    //initialize player if for some reason it's not
    if (!player.isInitialized) {
      await player.init();
    }

    //dispose all audio sources for layersPool if patch is true
    if (patch) {
      currentLayerPlayerPool?.disposePoolSources();
    }

    Future<void> setLayerPlayerPool(
        String filePath, String audioFileName, String layer) async {
      try {
        AudioSource audioSource = await player.loadFile(filePath);
        currentlyLoadedFiles.add(audioFileName);
        notifyListeners();
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

    // Future<void> setMainPlayer(String filePath) async {
    //   try {
    //     AudioSource audioSource = await player.loadFile(filePath);
    //     mainPlayer = MainPlayer(audioSource: audioSource, player: player);
    //     log('mainPlayer set');
    //     notifyListeners();
    //   } catch (e) {
    //     log(e.toString());
    //   }
    // }

    Future<void> loadAudioFiles(SectionLayer sectionLayer) async {
      final String layerAudioFileName = getAudioFileNAme(sectionLayer.audioUrl);
      log('audioFileName: $layerAudioFileName, audioUrl: ${sectionLayer.audioUrl}');

      //layer file
      final layerFile = await persistentController.readAudioFile(
          sessionScore!.id, layerAudioFileName, sectionLayer.audioUrl);
      if (layerFile.bytes.isNotEmpty) {
        layerFilesDownloaded++;
        notifyListeners();
        await setLayerPlayerPool(
            layerFile.path, layerAudioFileName, sectionLayer.layer);
      }
    }

    //SET MAIN PLAYER, NOT DOING ANYTHING RIGHT NOW
    // final String audioFileName = getAudioFileNAme(getAudioUrl(section));
    // final file = await persistentController.readAudioFile(
    //     sessionScore!.id, audioFileName, getAudioUrl(section));
    // await setMainPlayer(file.path);
    //

    for (final String layer in section.layers!) {
      sectionLayers.add(SectionLayer(
          layer: layer, audioUrl: getAudioLayerUrl(section, layer)));
    }

    //getting section layer audio files
    for (final sectionLayer in sectionLayers) {
      handleLoadLayerFiles.add(loadAudioFiles(sectionLayer));
    }

    notifyListeners();

    await Future.wait(handleLoadLayerFiles);

    LayerPlayerPool addPlayerPool() {
      final layerPlayerPool = LayerPlayerPool(
          sectionIndex: section.sectionIndex,
          sectionKey: section.key,
          tempo: section.userLayerTempo ?? section.defaultTempo,
          layers: sectionLayers,
          mainPlayer: null,
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

  Future<void> resetMixer() async {
    for (final layer in layerPlayersPool.globalLayers) {
      layerPlayersPool.setGlobalLayerVolume(1, layer.layerName);
    }
    if (currentLayerPlayerPool != null) {
      for (final SoundHandle handle
          in currentLayerPlayerPool!.activeLayerHandles) {
        player.setVolume(handle, 1);
      }
    }
    await updateLayersPrefs();
    notifyListeners();
  }

  Future<void> setLayersEnabled(bool value) async {
    layersEnabled = value;
    layerFilesDownloading = true;
    layerFilesDownloaded = 0;
    appState = AppState.loading;
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
          layerFilesLoading = true;
          await setSectionLayersPlayerPool(section, false);

          //if tempo selected by user doesn't exist in tempoLayersRange set it to default
          if (section.userTempo != null &&
              !userTempoIsInLayers(section.userTempo!, section)) {
            final int index = section.tempoRange.indexOf(section.defaultTempo);
            await patchPoolIfNotInLayersTempoRange(index, section);
          }

          await setGlobalLayers();
        }
      }
    }
    toggleMainOrLayerVolume(layersEnabled);

    layerFilesLoading = false;
    layerFilesDownloading = false;
    appState = AppState.idle;
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

  void toggleMainOrLayerVolume(bool value) {
    //if playing toggle volume for main and layer players
    void toggleActiveLayers(bool value) {
      if (isPlaying) {
        //set main player active and turn off layers
        if (!value) {
          //main player volume to mainPlayerVolume(1)
          player.setVolume(activeHandle!, mainPlayerVolume);
          //turn off layers, set layer players volume to 0
          for (final SoundHandle handle
              in currentLayerPlayerPool!.activeLayerHandles) {
            player.setVolume(handle, 0);
          }
        } else {
          //main player volume to 0
          player.setVolume(activeHandle!, mainPlayerVolume);

          if (currentLayerPlayerPool?.activeLayerHandles != null) {
            //set layer players volume to layerPlayersPool.globalLayers
            for (Layer layer in layerPlayersPool.globalLayers) {
              layerPlayersPool.setIndividualLayerVolume(
                  currentLayerPlayerPool!, layer.layerName, layer.layerVolume);
            }
          }
        }
      }
    }

    //if layers enabled, set main player volume to 0, and set global layer volume to 1
    if (value) {
      mainPlayerVolume = 0;
      toggleActiveLayers(value);
    } else {
      //if layers disabled, set main player volume to 1, and set global layer volume to 0
      mainPlayerVolume = 1;
      toggleActiveLayers(value);
    }
    notifyListeners();
  }

  Future<void> playLayers() async {
    log('play layers, ');

    if (currentLayerPlayerPool != null) {
      await Future.forEach(currentLayerPlayerPool!.players, (pool) async {
        pool.playerVolume = layerPlayersPool.globalLayers
            .firstWhere((p) => p.layerName == pool.layer)
            .layerVolume;
        pool.activeHandle = await player.play(pool.audioSource);
        player.setVolume(pool.activeHandle!, pool.playerVolume!);
      });
    }
  }

  Future<void> stopLayers() async {
    final p = currentLayerPlayerPool;
    if (p != null && p.activeLayerHandles.isNotEmpty) {
      await Future.forEach(p.activeLayerHandles, (handle) async {
        await player.stop(handle);
      });
    }

    // log('stop layers: $handle');
  }

  bool userTempoIsInLayers(int userTempo, Section section) {
    if (currentSection == null || currentSection!.tempoRangeLayers == null) {
      return false;
    }

    if (currentSection!.tempoRangeLayers!.contains(userTempo)) {
      return true;
    }

    return false;
  }

  Future<void> patchPoolIfNotInLayersTempoRange(
      int index, Section section) async {
    final poolToPatch =
        playerPool.firstWhere((pool) => pool.sectionKey == section.key);

    final audioUrl = section.fileList[index];
    final audioFileName = audioUrl.split('/').last;
    log('patchPoolIfNotInLayersTempoRange, audioFileName: $audioFileName');
    currentlyLoadedFiles.add(audioFileName);
    final file = await persistentController.readAudioFile(
        currentSection!.scoreId, audioFileName, audioUrl);
    if (file.bytes.isNotEmpty) {
      poolToPatch.audioSource = await player.loadFile(file.path);
    } else {
      poolToPatch.audioSource = await player.loadUrl(audioUrl);
    }

    notifyListeners();
  }

//LAYERS

  Future<void> setPlayerPool() async {
    filesDownloaded = 0;
    filesDownloading = true;
    final loadAudioFiles = <Future>[];
    final audioUrls = <AudioUrl>[];
    final audioFilesUrls = <AudioUrl>[];
    await player.init(bufferSize: 256, sampleRate: 48000);
    player.setVisualizationEnabled(true);
    player.setFftSmoothing(0.93);
    setGlobalVolume(globalVolume);

    for (Section section in playlist) {
      final audioUrl = getAudioUrl(section);
      audioUrls.add(AudioUrl(section.sectionIndex, section.key, audioUrl));
    }

    Future<void> loadFile(AudioUrl audioUrl) async {
      final scoreId = playlist[0].scoreId;
      final String audioFileName = getAudioFileNAme(audioUrl.url);
      currentlyLoadedFiles.add(audioFileName);

      final file = await persistentController.readAudioFile(
          scoreId, audioFileName, audioUrl.url);
      filesDownloaded++;
      notifyListeners();
      audioFilesUrls
          .add(AudioUrl(audioUrl.sectionIndex, audioUrl.sectionKey, file.path));
    }

    for (final audioUrl in audioUrls) {
      loadAudioFiles.add(loadFile(audioUrl));
    }
    filesDownloading = false;
    notifyListeners();

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

  String getAudioFileNAme(String audioUrl) {
    return audioUrl.split('/').last;
  }

  void setDefaultTempos() {
    lastUsedTempo = currentSection?.defaultTempo ?? 0;
    currentTempo = currentSection?.userTempo ?? currentSection?.defaultTempo;
  }

  //create array of AudioPlayers for all sections in playlist
  Future<void> initSessionPlayers(String sectionKey) async {
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
    mainPlayerVolume = value;
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
        await player.disposeSource(currentPool.audioSource);
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
    //if the next section is set to skip
    if (currentSection?.muted == true) {
      playNextSection();
      log('skipping muted section');
    } else {
      activeHandle = await player.play(currentAudioSource()!);
      // player.setVolume(activeHandle!, playerVolume * volumeMultiplier);
      log('player volume: ${player.getVolume(activeHandle!)}');
    }
    isPlaying = true;
    notifyListeners();
  }

  void getCurrentPosition() {
    currentPosition = player.getPosition(activeHandle!);
    doublePressGuard = currentPosition.inMilliseconds > 0 &&
        currentPosition.inMilliseconds < continueGuardTimer;
    notifyListeners();
  }

  void handleAutoContinue(Duration position) {
    if (position.inMilliseconds >=
            autoContinueMarker! - autoContinueExecutionOffset &&
        position.inMilliseconds - 20 < autoContinueMarker! + 20) {
      // jumped = true;
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

  void handleStartPlayback() {
    ticker = Ticker((elapsed) {
      if (isPlaying) {
        handlePlaybackAndMetronome();
        handleStop();
      }
    });
    ticker.start();
  }

  void handlePlayNextSection() {
    //only when autoContinue switch in section is on
    if (currentSection!.autoContinue == true) {
      // jumped = true;
      log('currentPosition: ${currentPosition.inMilliseconds.toString()}, autoContinueMarker: ${autoContinueMarker.toString()}');
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

//METRONOME
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
//METRONOME

//PLAYBACK
  Future<void> play() async {
    ticker.stop();
    // jumped = false;
    currentPosition = Duration.zero;
    notifyListeners();
    getDuration();
    if (!layersEnabled) setGlobalVolume(globalVolume);

    if (currentSection?.layers != null && layersEnabled) {
      await playLayers();
      toggleMainOrLayerVolume(true);
    } else {
      await stopLayers();
      // toggleMainOrLayerVolume(false);
      layersEnabled = false;
    }

    await playCurrentSection();
    player.setVolume(activeHandle!, mainPlayerVolume);
    isPlaying = true;
    // getPositionStream(); //test position Stream
    startMetronome();
    handleStartPlayback();
    initImagesOrder();
    setAdjustedMarkerPosition();
    imageProgress = true;
    notifyListeners();
    // log('isPlaying: $isPlaying');

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

    //swap images to the next one in 5000ms
    Future.delayed(Duration(milliseconds: autoContinueOffset),
        () => isPlaying ? swapImages() : null);
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

  Future<void> skip() async {
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
    // positionSub?.cancel();
    notifyListeners();
  }

  Future<void> playPreviousSection() async {
    _currentSectionIndex = (_currentSectionIndex - 1) % playlist.length;
    setCurrentSectionAndMovementKey();
    jumped = false;
    await play();
    // setCurrentSectionImage();
    setAdjustedMarkerPosition();
  }

  Future<void> playNextSection() async {
    _currentSectionIndex++;
    setCurrentSectionAndMovementKey();
    // jumped = false;
    await play();
  }

  Future<void> skipToNextSection() async {
    if (_currentSectionIndex < playlist.length - 1) {
      if (isPlaying) {
        await skip();
        await playNextSection();
      } else {
        _currentSectionIndex++;
        setCurrentSectionAndMovementKey();
      }
      setAdjustedMarkerPosition();
    }
  }

  Future<void> skipToPreviousSection() async {
    if (_currentSectionIndex > 0) {
      if (isPlaying) {
        await skip();
        await playPreviousSection();
      } else {
        _currentSectionIndex--;
        setCurrentSectionAndMovementKey();
      }
      setAdjustedMarkerPosition();
    }
  }
//PLAYBACK

//MARKER POSITION

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
//MARKER POSITION

//CLICKDATA
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
//CLICKDATA

  void setUserTempo(int tempo) async {
    currentTempo = tempo;
    if (currentTempo != currentSection?.userTempo ||
        currentTempo != currentSection?.defaultTempo) {
      appState = AppState.loading;
      notifyListeners();
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

    appState = AppState.idle;
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

  Color setColor() {
    return currentSection?.autoContinueMarker != null &&
            currentSection?.autoContinue != false
        ? greenColor
        : redColor;
  }

  Color setInactiveColor() {
    return currentSection?.autoContinueMarker != null &&
            currentSection?.autoContinue != false
        ? greenColor.withOpacity(0.3)
        : redColor.withOpacity(0.3);
  }

  Future<void> updateLayersPrefs() async {
    if (currentSection == null) {
      return;
    }
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
      muted: section.muted,
      layers: layerPlayersPool.globalLayers.isNotEmpty
          ? layerPlayersPool.globalLayers
          : null,
    );

    return sectionPrefs;
  }

  void clearSession() {
    playlist.clear();
    sessionMovements.clear();
    currentlyLoadedFiles.clear();
    totalLayerFiles = 0;
    sessionScore = null;
    showPrompt = false;
    notifyListeners();
  }

//IMAGES
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
//IMAGES
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
