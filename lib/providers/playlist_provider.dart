import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:gphil/controllers/audio_manager.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/db.dart';
import 'package:gphil/services/session_service.dart';
import 'package:gphil/theme/constants.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pc = PersistentDataController();

class PlaylistProvider extends ChangeNotifier {
  final Logger _log = Logger('PlaylistProvider');

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
    OrchestraLayer.woodwinds,
    OrchestraLayer.brass,
    OrchestraLayer.percussion,
    OrchestraLayer.strings
  ];
  int layersEnabledOnce = 0;
  AppState? appState;

  PlaylistProvider() {
    appState = AppState.idle;
    layersEnabled = false;
    _performanceMode = false;
    reset();
  }

//MODES
  bool tempoForAllSectionsEnabled = false;
  bool onePedalMode = false;
  bool layersEnabled = false;
  bool _performanceMode = false;
  bool sectionsColorized = false;

//IMAGES
  File? currentSectionImage;
  File? nextSectionImage;
  bool imagesSwapped = false;
  bool imageProgress = false;

// LOADING
  int totalLayerFiles = 0;
  int filesDownloaded = 0;
  int layerFilesDownloaded = 0;
  int filesLoaded = 0;
  int layerFilesLoaded = 0;
  bool filesDownloading = false;
  bool layerFilesDownloading = false;
  bool isLoading = false;
  bool layerFilesLoading = false;
  List<String> currentlyLoadedFiles = [];
  List<WebAudioUrl> webAudioUrls = [];
  List<AudioUrl> audioFilesUrls = [];
  int messageDismissTime = 2000;
  int errorDismissTime = 4000;
  String message = "";
  String error = "";

// AUTO CONTINUE
  int autoContinueOffset = 5000;
  late Duration _autoContinueAt;
  bool doublePressGuard =
      true; // avoid pressing pedal twice by mistake and earlier than needed
  bool showPrompt = false;
  double adjustedAutoContinuePosition = 0; // 0 - 100, percentage
  final int autoContinueExecutionOffset =
      0; // ms earlier than actuall auto continue marker
  double guardPosition = 0; // 0 - 100, percentage
  int?
      autoContinueMarker; // in milliseconds, default Timer delay for auto continue function
  int autoContinueMarkerIfSeeked = 0; //adjusted marker if seeked during playing
  Timer? autoContinueTimer; // timer for auto continue in play function

// LOOPING
  bool loopStropped = false;
  Timer? loopingTimer; // timer for looping function

// AUDIO PLAYERS
  List<PlayerAudioSource> playerAudioSources = [];
  final player = AudioManager().soloud;
  SoundHandle? activeHandle;
  SoundHandle? passiveHandle;
  final playerPool = <PlayerPool>[];
  bool _isPlaying = false;
  Ticker ticker = Ticker((elapsed) {});
  double globalVolume = 1.0;
  double playerVolume = 1.0;
  double volumeMultiplier = 2.0;
  final GlobalLayerPlayerPool layerPlayersPool = GlobalLayerPlayerPool(
    globalLayers: [],
  );

// DURATIONS
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  // Stream<int> position = Stream<int>.value(0);
  // StreamSubscription? positionSub;

// METRONOME
  List<SectionClickData> playlistClickData = [];
  ClickData currentBeat = ClickData(time: 0, beat: 0);
  int currentBeatIndex = 0;
  int? _previousBeatIndex;
  int beatLength = 0;
  List<PlaylistDuration> currentPlaylistDurations = [];
  bool isLeft = true;
  bool isStarted = false;
  Timer? metronomeTimer;
  int lastUsedTempo = 0;
  bool metronomeMuted = true;
  double metronomeVolume = 0.5;
  SoundHandle? metronomeHandle;
  AudioSource? metronomeClick;
  AudioSource? metronomeBell;
  SoundHandle? metronomeBellHandle;
  bool metronomeBellEnabled = true;
  final int _metronomeOffesetDelay = 40; //milliseconds
  late int? currentTempo =
      currentSection?.userTempo ?? currentSection?.defaultTempo;

//SESSION
  bool sessionLoaded = false;
  bool sessionChanged = false;

// GETTERS
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
  bool get areAllTempoRangesEqual {
    if (currentMovementSections.isEmpty) {
      return false;
    }

    List<int> firstTempoRange = currentMovementSections.first.tempoRange;

    return currentMovementSections.every((section) {
      if (section.tempoRange.length != firstTempoRange.length) {
        return false;
      }
      for (int i = 0; i < firstTempoRange.length; i++) {
        if (section.tempoRange[i] != firstTempoRange[i]) {
          return false;
        }
      }
      return true;
    });
  }

  bool get isTempoInAllRanges {
    if (currentMovementSections.isEmpty) {
      return false;
    }

    return currentMovementSections.every((section) {
      return section.tempoRangeLayers?.contains(section.userTempo) ?? false;
    });
  }

  List<Section> get tempoIsNotInThoseSections {
    if (currentMovementSections.isEmpty) {
      return [];
    }

    return currentMovementSections.where((section) {
      return section.tempoRangeLayers != null
          ? !section.tempoRangeLayers!.contains(section.userTempo ??
              section.userLayerTempo ??
              section.defaultTempo)
          : false;
    }).toList();
  }

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

  //METRONOME
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

  //MODES
  bool get layersHasBeenEnabled => layersEnabledOnce > 0;
  bool get performanceMode => _performanceMode;
  bool get isSectionLooped => currentSection?.looped ?? false;
  bool get isSkippingActive {
    if (currentSection?.muted == true && !performanceMode) {
      return true;
    } else {
      return false;
    }
  }

  bool get isLoopingActive {
    if (currentSection?.looped == true && !performanceMode) {
      return true;
    } else {
      return false;
    }
  }

// SETTERS

  set setPerformanceMode(bool value) {
    _performanceMode = value;
    loopStropped = value;
    notifyListeners();
  }

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

//METHODS
// MESSAGING
  void setMessage(String value) {
    message = value;
    notifyListeners();
  }

  void setError(String value) {
    error = value;
    notifyListeners();
  }

  void dismissMessage() async {
    Future.delayed(Duration(milliseconds: messageDismissTime), () {
      message = "";
      notifyListeners();
    });
  }

  void dismissError() async {
    Future.delayed(Duration(milliseconds: errorDismissTime), () {
      error = "";
      notifyListeners();
    });
  }

  reset() {
    message = "";
    error = "";
  }

// SET MODES
  void toggleSectionSkipped(String key) async {
    final Section section =
        playlist.firstWhere((element) => element.key == key);
    section.muted = !section.muted;
    log('muted: ${section.muted}');
    notifyListeners();
    await saveSectionPrefs(currentSection!);
  }

  void toggleSectionLooped() async {
    if (currentSection != null) {
      currentSection!.looped = !currentSection!.looped;
      if (currentSection!.looped) {
        currentSection!.muted = false;
      }
      notifyListeners();
      if (isLoopingActive && isPlaying) handleLooping(currentPosition);
      await saveSectionPrefs(currentSection!);
    }
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

  void setSectionsColorized(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    sectionsColorized = value;
    await prefs.setBool('sectionsColorized', value);
    notifyListeners();
  }

  void getSectionsColorized() async {
    final prefs = await SharedPreferences.getInstance();
    sectionsColorized = prefs.getBool('sectionsColorized') ?? false;
    notifyListeners();
  }

  void tempoForAllSections(bool value) async {
    tempoForAllSectionsEnabled = value;
    notifyListeners();
  }

// LAYERS
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

  Future<void> setSectionLayersPlayerPool(Section section, bool patch,
      [int? tempo]) async {
    if (!player.isInitialized) {
      await player.init();
    }

    if (patch) {
      await _disposeExistingPool(section);
    }

    final sectionLayers = _createSectionLayers(section);
    final layerPlayers = await _loadLayerPlayers(section, sectionLayers);

    _addOrUpdatePlayerPool(section, sectionLayers, layerPlayers, patch, tempo);
  }

  Future<void> _disposeExistingPool(Section section) async {
    final index = layerPlayersPool.globalPools
        .indexWhere((pool) => pool.sectionKey == section.key);
    if (index != -1) {
      final poolToDispose = layerPlayersPool.globalPools[index];
      poolToDispose.disposePoolSources();
    }
  }

  List<SectionLayer> _createSectionLayers(Section section) {
    return section.layers
            ?.map((layer) => SectionLayer(
                layer: layer, audioUrl: getAudioLayerUrl(section, layer)))
            .toList() ??
        [];
  }

  Future<List<LayerPlayer>> _loadLayerPlayers(
      Section section, List<SectionLayer> sectionLayers) async {
    final layerPlayers = <LayerPlayer>[];
    setMessage("Loading files...");

    for (final sectionLayer in sectionLayers) {
      await _loadAndAddLayerPlayer(section, sectionLayer, layerPlayers);
    }

    setMessage("Ready");
    return layerPlayers;
  }

  Future<void> _loadAndAddLayerPlayer(Section section,
      SectionLayer sectionLayer, List<LayerPlayer> layerPlayers) async {
    final String layerAudioFileName = getAudioFileNAme(sectionLayer.audioUrl);
    log('audioFileName: $layerAudioFileName, audioUrl: ${sectionLayer.audioUrl}');

    final layerFile = await pc.readAudioFile(
        sessionScore!.id, layerAudioFileName, sectionLayer.audioUrl);

    if (layerFile.bytes.isNotEmpty) {
      layerFilesDownloaded++;
      notifyListeners();
      await _addLayerPlayer(section, layerFile.path, layerAudioFileName,
          sectionLayer.layer, layerPlayers);
    }
  }

  Future<void> _addLayerPlayer(
      Section section,
      String filePath,
      String audioFileName,
      String layer,
      List<LayerPlayer> layerPlayers) async {
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

  void _addOrUpdatePlayerPool(Section section, List<SectionLayer> sectionLayers,
      List<LayerPlayer> layerPlayers, bool patch, int? tempo) {
    final layerPlayerPool = LayerPlayerPool(
        sectionIndex: section.sectionIndex,
        sectionKey: section.key,
        tempo: tempo ?? section.userLayerTempo ?? section.defaultTempo,
        layers: sectionLayers,
        mainPlayer: null,
        players: layerPlayers);

    if (patch) {
      final index = layerPlayersPool.globalPools
          .indexWhere((pool) => pool.sectionKey == section.key);
      layerPlayersPool.globalPools[index] = layerPlayerPool;
    } else {
      layerPlayersPool.globalPools.add(layerPlayerPool);
    }
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
    //if layers were not enabled yet and player is already playing
    if (!layersHasBeenEnabled && isPlaying) {
      stop();
    }
    if (tempoIsNotInThoseSections.isNotEmpty) {
      setError("Some of your tempo preferences are not available in layers");
      return;
    }

    if (currentTempo != null &&
        currentSection != null &&
        !userTempoIsInLayers(currentTempo!, currentSection!)) {
      setError("Current tempo is not available in layers");
      dismissError();
      return;
    } else {
      if (totalLayerFiles == 0) {
        for (Section section
            in playlist.where((section) => section.layers != null)) {
          //check if files are there already
          if (layerPlayersPool.globalPools.isNotEmpty &&
              layerPlayersPool.globalPools
                  .any((element) => element.sectionKey == section.key)) {
            continue;
          } else {
            layerFilesDownloaded = 0;
            layerFilesDownloading = true;
            layerFilesLoading = true;
            appState = AppState.loading;
            notifyListeners();
            await setSectionLayersPlayerPool(section, false);

            //if tempo selected by user doesn't exist in tempoLayersRange set it to default
            if (section.userTempo != null &&
                !userTempoIsInLayers(section.userTempo!, section)) {
              final int index =
                  section.tempoRange.indexOf(section.defaultTempo);
              await patchPoolIfNotInLayersTempoRange(index, section);
            }

            await setGlobalLayers();
          }
        }
      }

      layersEnabled = value;
      if (layersEnabledOnce == 0) layersEnabledOnce++;
      layerFilesLoading = false;
      layerFilesDownloading = false;
      log('layerFilesLoaded: $layerFilesLoaded, totalLayerFiles: $totalLayerFiles');
      toggleMainPlayerVolume();
      appState = AppState.idle;
      currentTempo =
          currentSection?.userLayerTempo ?? currentSection?.defaultTempo;
      setMessage("Ready");
      notifyListeners();
    }
  }

  Future<void> setGlobalLayers() async {
    final sectionPrefsList = <SectionPrefs>[];
    for (Section section
        in playlist.where((section) => section.layers != null)) {
      final prefs = await pc.readSectionJsonFile(sessionScore!.id, section.key);

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
      for (final SoundHandle handle
          in currentLayerPlayerPool!.activeLayerHandles) {
        player.setVolume(handle, 0);
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
    final file = await pc.readAudioFile(
        currentSection!.scoreId, audioFileName, audioUrl);
    if (file.bytes.isNotEmpty) {
      poolToPatch.audioSource = await player.loadFile(file.path);
    } else {
      poolToPatch.audioSource = await player.loadUrl(audioUrl);
    }

    notifyListeners();
  }

// INIT
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

  AudioSource? getAudioSource(String sectionKey) {
    return playerAudioSources.isNotEmpty
        ? playerAudioSources
            .firstWhere((source) => source.sectionKey == sectionKey)
            .audioSource
        : null;
  }

  Future<void> playSection(Section section) async {
    appState = AppState.loading;
    await initPlayer();
    await player.disposeAllSources();

    final audioUrl = getAudioUrl(section);
    final audioFileName = getAudioFileNAme(audioUrl);
    currentlyLoadedFiles.add(audioFileName);
    final file =
        await pc.readAudioFile(section.scoreId, audioFileName, audioUrl);
    dismissMessage();
    if (file.bytes.isNotEmpty) {
      // setMessage('audioSource loading');

      final AudioSource audioSource = await player.loadFile(file.path);
      // setMessage('audioSource loaded, $audioSource');
      // playerAudioSources.add(PlayerAudioSource(audioSource, section.key));
      activeHandle = await player.play(audioSource);
      isPlaying = true;
      appState = AppState.idle;
      notifyListeners();
    } else {
      // setMessage('Loading URL, $audioUrl');
      final audioSource = await player.loadUrl(audioUrl);

      // playerAudioSources.add(PlayerAudioSource(audioSource, section.key));
      activeHandle = await player.play(audioSource);
      isPlaying = true;
      appState = AppState.idle;
      notifyListeners();
    }
  }

  int getTempoIndex(Section section) {
    return section.userTempo != null
        ? section.tempoRange.indexOf(section.userTempo!)
        : section.tempoRange.indexOf(section.defaultTempo);
  }

  String getAudioUrl(Section section) {
    return section.fileList[getTempoIndex(section)];
  }

  Future<void> setPlayerPool(bool isSessionLoading) async {
    await _initializePlayerAndPrefs(isSessionLoading);
    final audioUrls = _getAudioUrls();
    await _loadAudioFiles(audioUrls);
    await _createPlayerPool();
  }

  Future<void> _initializePlayerAndPrefs(bool isSessionLoading) async {
    currentlyLoadedFiles.clear();
    webAudioUrls.clear();
    audioFilesUrls.clear();
    filesLoaded = 0;
    filesDownloaded = 0;
    filesDownloading = true;

    try {
      await initPlayer();
      //loading metronome sounds
      metronomeClick =
          await player.loadAsset('assets/audio/metronome_click.wav');
      metronomeBell = await player.loadAsset('assets/audio/metronome_bell.wav');
    } catch (e) {
      setError('Player initialization error: $e');
    }

    if (isSessionLoading) {}

    if (!kIsWeb && !isSessionLoading) {
      for (Section section in playlist) {
        await loadSectionPrefs(section);
      }
    }

    getMetronomeData();
  }

  List<AudioUrl> _getAudioUrls() {
    return playlist.map((section) {
      final audioUrl = getAudioUrl(section);
      return AudioUrl(section.sectionIndex, section.key, audioUrl);
    }).toList();
  }

  Future<void> _loadAudioFiles(List<AudioUrl> audioUrls) async {
    setMessage("Getting files...");
    final futures = audioUrls.map((audioUrl) => _loadFile(audioUrl));
    await Future.wait(futures);
    filesDownloading = false;
    notifyListeners();
  }

  Future<void> _loadFile(AudioUrl audioUrl) async {
    final scoreId = playlist[0].scoreId;
    final String audioFileName = getAudioFileNAme(audioUrl.url);
    currentlyLoadedFiles.add(audioFileName);

    if (kIsWeb) {
      await _loadWebFile(scoreId, audioFileName, audioUrl);
    } else {
      await _loadDesktopFile(scoreId, audioFileName, audioUrl);
    }
  }

  Future<void> _loadWebFile(
      String scoreId, String audioFileName, AudioUrl audioUrl) async {
    final file = await DB().readAudioFile(scoreId, audioFileName, audioUrl.url);
    webAudioUrls.add(WebAudioUrl(audioUrl.url, file.key, audioUrl.sectionIndex,
        audioUrl.sectionKey, file.bytes));
    filesDownloaded++;
    notifyListeners();
  }

  Future<void> _loadDesktopFile(
      String scoreId, String audioFileName, AudioUrl audioUrl) async {
    final file = await pc.readAudioFile(scoreId, audioFileName, audioUrl.url);
    audioFilesUrls
        .add(AudioUrl(audioUrl.sectionIndex, audioUrl.sectionKey, file.path));
    filesDownloaded++;
    notifyListeners();
  }

  Future<void> _createPlayerPool() async {
    final audioSources = kIsWeb ? webAudioUrls : audioFilesUrls;

    audioSources.sort((a, b) {
      if (a is AudioUrl && b is AudioUrl) {
        return a.sectionIndex.compareTo(b.sectionIndex);
      } else if (a is WebAudioUrl && b is WebAudioUrl) {
        return a.sectionIndex.compareTo(b.sectionIndex);
      }
      return 0; // Default case, should not happen if types are consistent
    });

    for (final audioSource in audioSources) {
      try {
        final source = kIsWeb
            ? await player.loadUrl((audioSource as WebAudioUrl).url)
            : await player.loadFile((audioSource as AudioUrl).url);

        if (audioSource is AudioUrl) {
          playerPool.add(PlayerPool(
              sectionIndex: audioSource.sectionIndex,
              sectionKey: audioSource.sectionKey,
              audioSource: source));
        } else if (audioSource is WebAudioUrl) {
          playerPool.add(PlayerPool(
              sectionIndex: audioSource.sectionIndex,
              sectionKey: audioSource.sectionKey,
              audioSource: source));
        }

        filesLoaded++;
        notifyListeners();
      } catch (e) {
        setError('Error loading audio source: $e');
      }
    }
  }

  void resetPlayers() async {
    if (player.isInitialized) await player.disposeAllSources();
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

  //create array of AudioPlayers for all sections in playlist
  Future<void> initSessionPlayers(String sectionKey,
      {bool isSessionLoading = false}) async {
    isLoading = true;
    //checking if globalLayers exist in the current score
    if (sessionScore?.globalLayers == null) layersEnabled = false;
    resetPlayers();

    setMessage("Starting...");
    await loadClickFiles(playlist);
    await setPlayerPool(isSessionLoading);
    setGlobalPlaylistLayers();
    if (layersEnabled) setLayersEnabled(layersEnabled);

    //set current section image and duration if not empty
    if (playerPool.isNotEmpty &&
        _currentSectionIndex <= playerPool.length - 1) {
      // setCurrentSectionImage();
      setCurrentSectionByKey(sectionKey);
      getDuration();
    }

    setDefaultTempos();
    setAdjustedMarkerPosition();
    getSectionsColorized();
    getOnePedalMode();
    isLoading = false;
    setMessage("Ready");
    notifyListeners();
  }

  String getAudioFileNAme(String audioUrl) {
    return audioUrl.split('/').last;
  }

  void setDefaultTempos() {
    lastUsedTempo = currentSection?.defaultTempo ?? 0;
    currentTempo = currentSection?.userTempo ?? currentSection?.defaultTempo;
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
      !kIsWeb
          ? player.setGlobalVolume(globalVolume * volumeMultiplier)
          : player.setGlobalVolume(globalVolume);
    }
  }

  void setMainPlayerVolume(double value) {
    playerVolume = value;
    notifyListeners();
  }

  Future<void> patchPool(int tempo, Section section) async {
    final currentPool = pool(section.key);
    final int tempoindex = section.tempoRange.indexOf(tempo);
    setMessage("Updating audio...");
    // if (tempoindex != null) {
    final audioUrl = section.fileList[tempoindex];
    final audioFileName = audioUrl.split('/').last;
    currentlyLoadedFiles.add(audioFileName);
    final file =
        await pc.readAudioFile(section.scoreId, audioFileName, audioUrl);
    if (file.bytes.isNotEmpty && currentPool != null) {
      await player.disposeSource(currentPool.audioSource);
      currentPool.audioSource = await player.loadFile(file.path);
    } else {
      currentPool?.audioSource = await player.loadUrl(audioUrl);
    }
    getDuration();
    // adjust the timing for autoContinue
    setAdjustedMarkerPosition();
    setMessage("Ready");
    notifyListeners();
    // }
  }

  PlayerPool? currentPlayerPool() {
    return playerPool
        .firstWhere((pool) => pool.sectionKey == currentSectionKey);
  }

  PlayerPool? pool(String sectionKey) {
    return playerPool.firstWhere((pool) => pool.sectionKey == sectionKey);
  }

  AudioSource? currentAudioSource() {
    return currentPlayerPool()?.audioSource;
  }

// METRONOME
  // also plays metronome sounds
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
    if (currentPlaylistDurationBeats.isNotEmpty) {
      beatLength =
          (currentPlaylistDurationBeats[currentBeatIndex] / tempoDiff).round();
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
    final double metronomeAttenuation = 0.25;
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

// PLAYBACK
  Future<void> play() async {
    ticker.stop();
    currentPosition = Duration.zero;
    notifyListeners();
    getDuration();
    if (!layersEnabled) {
      setGlobalVolume(globalVolume);
    }

    if (currentSection?.layers != null && layersHasBeenEnabled) {
      //check if the tempo is in layers range
      if (userTempoIsInLayers(currentTempo!, currentSection!)) {
        await playLayers();
        toggleMainPlayerVolume();
      }
    }

    isPlaying = true;
    await playCurrentSection();
    playerVolume = currentSection?.sectionVolume ?? 1;
    player.setVolume(activeHandle!, playerVolume);
    startMetronome();
    handleStartPlayback();
    initImagesOrder();
    setAdjustedMarkerPosition();
    imageProgress = true;
    notifyListeners();

    if (autoContinueMarker != null && !isLoopingActive) {
      autoContinueTimer = Timer(
          Duration(
              milliseconds: autoContinueMarker! - autoContinueExecutionOffset),
          () => handlePlayNextSection());
      //Timer will be cancelled on stop or seek
    }

    //swap images to the next one in 5000ms
    if (!currentSection!.looped) {
      Future.delayed(Duration(milliseconds: autoContinueOffset),
          () => isPlaying ? swapImages() : null);
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
    autoContinueTimer?.cancel();
    loopingTimer?.cancel();
    ticker.stop();
    ticker.dispose();
    currentPosition = Duration.zero;
    stopMetronome();
    initImagesOrder();
    imageProgress = false;
    isPlaying = false;
    loopStropped = true;
    notifyListeners();
  }

  Future<void> skip() async {
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
    notifyListeners();
  }

  Future<void> playSelectedSection(String sectionKey) async {
    if (isPlaying) {
      await skip();
    }
    //find index of the section in playlist
    int index = playlist.indexWhere((element) => element.key == sectionKey);
    if (index != -1) {
      //set current section to the selected one
      currentSectionIndex = index;
      setCurrentSectionAndMovementKey();
    }
    if (isPlaying) {
      await play();
    }
  }

  Future<void> playCurrentSection() async {
    //if section is looped and loop was stopped

    //if the next section is set to skip
    if (currentSection?.muted == true && !performanceMode) {
      playNextSection();
      _log.warning('skipping muted section');
      return;
    }
    activeHandle = await player.play(currentAudioSource()!);

    if (isLoopingActive && loopStropped) {
      loopStropped = false;
    }
    //if section is looped, play it again
    if (!loopStropped && currentSection?.looped == true) {
      loopingTimer = Timer(
          Duration(milliseconds: duration.inMilliseconds),
          () => !performanceMode && currentSection!.looped
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
    _currentSectionIndex = (_currentSectionIndex - 1) % playlist.length;
    setCurrentSectionAndMovementKey();
    await play();
    // setCurrentSectionImage();
    setAdjustedMarkerPosition();
  }

  Future<void> playNextSection() async {
    _currentSectionIndex++;
    setCurrentSectionAndMovementKey();
    await play();
  }

  Future<void> skipToNextSection() async {
    if (_currentSectionIndex < playlist.length - 1) {
      if (isPlaying) {
        await skip();
        await playNextSection();
      } else {
        _currentSectionIndex++;
        setCurrentSectionByKey(playlist[_currentSectionIndex].key);
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
        setCurrentSectionByKey(playlist[_currentSectionIndex].key);
      }
      setAdjustedMarkerPosition();
    }
  }

  void getCurrentPosition() {
    if (activeHandle != null) {
      currentPosition = player.getPosition(activeHandle!);
      doublePressGuard = currentPosition.inMilliseconds > 0 &&
          currentPosition.inMilliseconds < continueGuardTimer;
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

    if (isLoopingActive) {
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
    if (currentSection!.autoContinue == true) {
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
      currentLayerPlayerPool?.seek(position);
    }

    //case when section autocontinues
    if (autoContinueMarker != null && !isLoopingActive) {
      handleNextSectionIfSeeked(position);
    } else {
      handleLooping(position);
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

// MARKER POSITION
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

    pc.updateSectionPrefs(
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

// CLICKDATA
  Future<List<ClickData>> loadClickData(Section section) async {
    List<ClickData> clickData;
    if (!kIsWeb) {
      clickData = await pc.readClickJsonFile(
          section.scoreId, section.key, section.clickDataUrl!);
    } else {
      clickData = await DB().loadClickData(section);
    }
    return clickData;
  }

  Future<SectionClickData> loadSectionClickData(Section section) async {
    List<ClickData> clickData = await loadClickData(section);
    SectionClickData sectionClickData =
        SectionClickData(section.key, clickData);
    return sectionClickData;
  }

  // Future<void> loadPlaylistClickData(Section section) async {
  //   SectionClickData sectionClickData = await loadSectionClickData(section);

  //   // set bet lengths for each clickdata
  //   currentPlaylistDurations
  //       .add(PlaylistDuration(sectionKey: section.key, beatLengths: []));
  //   notifyListeners();
  //   log('currentPlaylistDurations: ${currentPlaylistDurations.length}');

  //   for (int i = 0; i < sectionClickData.clickData.length - 1; i++) {
  //     final beatLength = sectionClickData.clickData[i + 1].time -
  //         sectionClickData.clickData[i].time;
  //     currentPlaylistDurations
  //         .firstWhere((element) => element.sectionKey == section.key)
  //         .beatLengths
  //         .add(beatLength);
  //   }

  //   void addPlaylistClickData(SectionClickData value) {
  //     playlistClickData.add(value);
  //   }

  //   addPlaylistClickData(sectionClickData);
  //   notifyListeners();
  // }

  Future<void> loadClickFiles(List<Section> sections) async {
    // Create new lists instead of clearing existing ones
    // final List<SectionClickData> newPlaylistClickData = [];
    // final List<PlaylistDuration> newPlaylistDurations = [];
    final List<Future<void>> futures = [];

    Future<void> loadSectionClicks(Section section) async {
      if (section.metronomeAvailable == true) {
        try {
          // Load click data for the section
          final SectionClickData sectionClickData =
              await loadSectionClickData(section);

          // Create new duration entry for this section
          final List<int> beatLengths = [];

          // Calculate beat lengths
          for (int i = 0; i < sectionClickData.clickData.length - 1; i++) {
            final beatLength = sectionClickData.clickData[i + 1].time -
                sectionClickData.clickData[i].time;
            beatLengths.add(beatLength);
          }

          // Add to new collections
          playlistClickData.add(sectionClickData);
          currentPlaylistDurations.add(
            PlaylistDuration(
              sectionKey: section.key,
              beatLengths: beatLengths,
            ),
          );

          log('Added durations for section ${section.key}: ${beatLengths.length} beats');
        } catch (e) {
          log('Error in loadClickFiles: $e');
        }
      }

      // Update state with new collections
      // playlistClickData = newPlaylistClickData;
      // currentPlaylistDurations = newPlaylistDurations;
      log('Final currentPlaylistDurations count: ${currentPlaylistDurations.length}');
      notifyListeners();
    }

    for (Section section in sections) {
      futures.add(loadSectionClicks(section));
    }

    Future.wait(futures);
  }

// SECTION MANAGEMENT
  void setUserTempo(int tempo, Section section) async {
    currentTempo = tempo;
    if (currentTempo != section.userTempo ||
        currentTempo != section.defaultTempo) {
      appState = AppState.loading;
      notifyListeners();
      await patchPool(tempo, section);
      section.userTempo = tempo;
      if (userTempoIsInLayers(tempo, section)) section.userLayerTempo = tempo;
      await saveSectionPrefs(section);

      //patching layers
      //if tempo was changed when layes were turned off but enabled once
      if (layersHasBeenEnabled &&
          currentLayerPlayerPool != null &&
          currentLayerPlayerPool!.tempo != currentTempo) {
        await setSectionLayersPlayerPool(section, true);
      }
      //if all sections tempo change is enabled, patch all layers
      if (layersEnabled && tempoForAllSectionsEnabled) {
        await setSectionLayersPlayerPool(section, true, tempo);
        for (final pool in layerPlayersPool.globalPools) {
          pool.tempo = tempo;
        }
      } else {
        // patch only current section layers
        if (layersEnabled && currentLayerPlayerPool?.tempo != tempo) {
          await setSectionLayersPlayerPool(section, true);
          currentLayerPlayerPool?.tempo = tempo;
          currentSection?.userLayerTempo = tempo;
        }
      }
    }
    log('tempoDiff: ${tempoDiff.toString()}');
    log('lastUsedTempo: ${lastUsedTempo.toString()}');
    log('current tempo: $currentTempo');

    appState = AppState.idle;
    lastUsedTempo = tempo;
    // sessionChanged = true;
    notifyListeners();
  }

  double setTempoDiff() {
    return currentTempo != null && currentSection != null
        ? currentTempo! / currentSection!.defaultTempo
        : 1;
  }

  //useful for the classical concertos, when there is a consistent tempo throughout the movement
  Future<void> setTempoForAllSections(int tempo) async {
    //set the tempo for all sections and patch the audio
    if (currentTempo != tempo) {
      currentlyLoadedFiles.clear();
      for (Section section in currentMovementSections) {
        setUserTempo(tempo, section);
      }
      // sessionChanged = true;
      notifyListeners();
    }
  }

  void setSectionVolume(Section section, double volume) async {
    final clampedVolume = volume.clamp(0.0, 2.0);
    log('Clamped volume: $clampedVolume');
    // Floor to 1 decimal place
    final flooredVolume = (clampedVolume * 10).round() / 10;
    log('Floored volume: $flooredVolume');
    section.sectionVolume = flooredVolume;
    if (isPlaying) {
      player.setVolume(activeHandle!, flooredVolume);
    }
    notifyListeners();
  }

  void resetSectionVolume(Section section) async {
    section.sectionVolume = 1.0;
    if (isPlaying) {
      player.setVolume(activeHandle!, section.sectionVolume!);
    }
    notifyListeners();
  }

  void resetAllSectionsVolume() async {
    final currentMovementSections = playlist.where((section) =>
        section.movementKey == currentMovementKey &&
        section.sectionVolume != 1.0);

    if (currentMovementSections.isNotEmpty) {
      for (Section section in currentMovementSections) {
        section.sectionVolume = 1.0;
        await saveSectionPrefs(section);
      }
    }
    if (isPlaying) {
      player.setVolume(activeHandle!, 1.0);
    }
    notifyListeners();
  }

// PLAYLIST MANAGEMENT
  bool containsMovement(String key) {
    return sessionMovements.any((element) => element.movementKey == key);
  }

  bool checkScoreAndPlaylistId(String scoreId) {
    return sessionMovements.any((el) => el.scoreId != scoreId);
  }

  void addMovement(Score score, Movement movement) {
    movementToAdd = movement;
    //check if sections from other concerto is already in the session playlist
    if (checkScoreAndPlaylistId(score.id)) {
      showPrompt = true;
      notifyListeners();
    } else {
      sessionMovements.add(SessionMovement(movement.key, score.id,
          movement.title, movement.index, movement.renderTail));
      sessionMovements.sort((a, b) => a.index.compareTo(b.index));
      sessionScore = score;
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
    if (sessionMovements.isEmpty) {
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
    notifyListeners();
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

  Future<void> loadNewSession(
      Score score, List<Movement> movements, SessionType sessionType) async {
    isLoading = true;
    //reset click data in case of hard loading
    stop();
    stopMetronome();
    playlistClickData.clear();
    currentBeatIndex = 0;
    if (playlist.isNotEmpty && sessionMovements.isNotEmpty) {
      playlist.clear();
      sessionMovements.clear();
    }
    sessionScore = score;
    //setting up session movements
    for (Movement movement in movements) {
      addMovement(score, movement);
    }

    //setting up playlist
    for (SessionMovement sessionMovement in sessionMovements) {
      final movementKey = sessionMovement.movementKey;

      for (Section section in movements
          .firstWhere((element) => element.key == movementKey)
          .setupSections) {
        playlist.add(section);
      }
    }

    for (Section section in playlist) {
      section.sectionIndex = playlist.indexOf(section);
      log('sectionIndex: ${section.sectionIndex.toString()}');
    }

    // await loadClickFiles(playlist);
    await initSessionPlayers(playlist.first.key, isSessionLoading: true);
    //set mode to practice or performance
    if (sessionType == SessionType.performance) {
      setPerformanceMode = true;
    } else {
      setPerformanceMode = false;
    }
    sessionLoaded = true;
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

    if (!kIsWeb) {
      setCurrentSectionImage();
    }
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

// PREFERENCES
  Future<void> updateLayersPrefs() async {
    if (currentSection == null) {
      return;
    }
    final SectionPrefs sectionPrefs = constructSectionPrefs(currentSection!);
    log('updateLayersPrefs: $sectionPrefs');
    pc.updateSectionPrefs(
        currentSection!.scoreId, currentSection!.key, sectionPrefs);
    notifyListeners();
  }

  Future<void> loadSectionPrefs(Section section) async {
    //read from file if exists
    final sectionPrefs =
        await pc.readSectionJsonFile(section.scoreId, section.key);

    //transform to SectionPrefs
    final currentPrefs =
        sectionPrefs != null ? SectionPrefs.fromJson(sectionPrefs) : null;

    //update section with prefs
    if (currentPrefs != null) {
      section.defaultTempo = currentPrefs.defaultTempo;
      section.userTempo = currentPrefs.userTempo;
      section.userLayerTempo = currentPrefs.userLayerTempo;
      section.autoContinue = currentPrefs.autoContinue;
      section.muted = currentPrefs.muted ?? false;
      section.looped = currentPrefs.looped ?? false;
      section.sectionVolume = currentPrefs.sectionVolume;
      // section.layers = currentPrefs.layers;
    }
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
      looped: section.looped,
      sectionVolume: section.sectionVolume,
      layers: layerPlayersPool.globalLayers.isNotEmpty
          ? layerPlayersPool.globalLayers
          : null,
    );

    return sectionPrefs;
  }

  Future<void> saveSectionPrefs(Section section) async {
    final SectionPrefs sectionPrefs = constructSectionPrefs(section);

    try {
      await pc.writeSectionJsonFile(section.scoreId, section.key, sectionPrefs);
      sessionChanged = true;
    } catch (e) {
      setError(e.toString());
    }
  }

// CLEAR SESSION
  void clearSession() {
    layersEnabled = false;
    playlist.clear();
    sessionMovements.clear();
    currentlyLoadedFiles.clear();
    filesLoaded = 0;
    totalLayerFiles = 0;
    sessionScore = null;
    showPrompt = false;
    notifyListeners();
  }

// IMAGES
  Future<void> setCurrentSectionImage() async {
    // currentSectionImage = null;
    if (sessionScore?.id != null && currentSection?.sectionImage != null) {
      log('currentSectionImage: ${currentSection!.sectionImage!.asset.ref}');
      currentSectionImage = await pc.readImageFile(
          sessionScore!.id, currentSection!.sectionImage!.asset.ref);
      notifyListeners();
    }
  }

  Future<void> setNextSectionImage() async {
    if (nextSection?.sectionImage != null) {
      nextSectionImage = await pc.readImageFile(
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
