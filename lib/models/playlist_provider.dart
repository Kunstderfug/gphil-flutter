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
import 'package:gphil/providers/score_provider.dart';

final persistentController = PersistentDataController();
final p = PlaylistProvider();
final a = AudioProvider();
final m = MetronomeProvider();

//test
const audioAssets = [
  'assets/audio/STEMS/RAVEL_G_1_EXPO_1_116_woodwinds.mp3',
  'assets/audio/STEMS/RAVEL_G_1_EXPO_1_116_brass.mp3',
  'assets/audio/STEMS/RAVEL_G_1_EXPO_1_116_percussion.mp3',
  'assets/audio/STEMS/RAVEL_G_1_EXPO_1_116_strings.mp3',
];

enum OrchestraLayer {
  flute,
  woodwinds,
  brass,
  percussion,
  strings,
}

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

class PlayerPool {
  final int sectionIndex;
  final String sectionKey;
  AudioSource audioSource;
  double? playerVolume;

  PlayerPool(
      {required this.sectionIndex,
      required this.sectionKey,
      required this.audioSource,
      this.playerVolume = 1.0});
}

class LayerPlayer extends PlayerPool {
  final String layer;
  bool isActive;
  bool isMuted = false;
  SoundHandle? activeHandle;
  SoLoud player;

  LayerPlayer({
    required super.sectionIndex,
    required super.sectionKey,
    required super.audioSource,
    super.playerVolume,
    required this.layer,
    this.activeHandle,
    this.isActive = true,
    required this.player,
  });

  void setPlayerVolume(double value) {
    playerVolume = value;
    if (activeHandle != null && playerVolume != null) {
      player.setVolume(activeHandle!, playerVolume!);
    }
  }
}

class Layer {
  final String layerName;

  Layer({required this.layerName});
  String get fullName {
    switch (layerName) {
      case 'f':
        return 'Flute';
      case 'w':
        return 'Woodwinds';
      case 'b':
        return 'Brass';
      case 'p':
        return 'Percussion';
      case 's':
        return 'Strings';
    }
    return 'Unnamed Layer';
  }
}

class LayerChannel {
  final String name;
  final double channelVolume;
  final LayerPlayer player;
  LayerChannel(
      {required this.name, required this.channelVolume, required this.player});

  String get channelName {
    switch (name) {
      case 'f':
        return 'Flute';
      case 'w':
        return 'Woodwinds';
      case 'b':
        return 'Brass';
      case 'p':
        return 'Percussion';
      case 's':
        return 'Strings';
    }
    return 'Unnamed Layer';
  }
}

class SectionLayer {
  final String layer;
  final String audioUrl;

  SectionLayer({required this.layer, required this.audioUrl});
}

class LayerPlayerPool {
  final int sectionIndex;
  final String sectionKey;
  final List<SectionLayer> layers;
  List<LayerPlayer> players;
  LayerPlayerPool(
      {required this.sectionIndex,
      required this.sectionKey,
      required this.layers,
      required this.players});

  List<SoundHandle> get activeLayerHandles =>
      players.where((p) => p.isActive).map((p) => p.activeHandle!).toList();
//getting liest of available channels
  List<LayerChannel> get layerChannels {
    List<LayerChannel> channels = [];
    for (LayerPlayer player in orderedPlayers) {
      channels.add(
        LayerChannel(
          name: player.layer,
          player: player,
          channelVolume: player.playerVolume ?? 0.0,
        ),
      );
    }
    return channels;
  }

  List<LayerPlayer> get activeChannels =>
      players.where((p) => p.isActive).toList();

  List<LayerPlayer> get orderedPlayers {
    List<LayerPlayer> orderedPlayers = [];
    int index = 0;
    for (SectionLayer layer in layers) {
      final currentPlayer = players.firstWhere((p) => p.layer == layer.layer);
      orderedPlayers.insert(index, currentPlayer);
      index++;
    }
    return orderedPlayers;
  }

//set individual channel volume
  void setChannelVolume(double volume, String layer) {
    for (LayerPlayer player in players) {
      if (player.layer == layer) {
        player.playerVolume = volume;
        player.setPlayerVolume(volume);
      }
    }
  }

  void setChannelActive(String layer, bool active) {
    for (LayerPlayer player in players) {
      if (player.layer == layer) {
        player.isActive = active;
      }
    }
  }

  void setChannelSoloOrMuted(String layer, bool value) {
    for (LayerPlayer player in players) {
      if (player.layer == layer) {
        player.playerVolume = value ? 1.0 : 0.0;
        player.isActive = value ? true : false;
        player.isMuted = value ? false : true;
      }
    }
  }

  void setSoloOrMutedReset() {
    for (LayerPlayer player in players) {
      player.playerVolume = 1.0;
      player.isActive = true;
      player.isMuted = false;
    }
  }
}

class GlobalLayerPlayerPool {
  final List<Layer> globalLayers;
  final List<LayerPlayerPool> globalPools;

  GlobalLayerPlayerPool(
      {required this.globalLayers, required this.globalPools});

  void resetPools() {
    globalPools.clear();
  }

  void resetLayers() {
    globalLayers.clear();
  }

  void resetAll() {
    resetPools();
    resetLayers();
  }
}

class AudioUrl {
  final int sectionIndex;
  final String sectionKey;
  final String url;

  AudioUrl(this.sectionIndex, this.sectionKey, this.url);
}

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
  final activeLayerHandles =
      <SoundHandle>[]; //when multiple layers are available for mixing
  SoundHandle? passiveHandle;
  final playerPool = <PlayerPool>[];
  bool _isPlaying = false;
  bool jumped = false;
  Ticker ticker = Ticker((elapsed) {});
  double globalVolume = 1;
  double playerVolume = 1;
  final GlobalLayerPlayerPool layerPlayersPool = GlobalLayerPlayerPool(
    globalLayers: [],
    globalPools: [],
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
              .firstWhere((element) => element.sectionKey == currentSectionKey)
          : null;

  ClickData? get currentBeatData =>
      currentClickData?.clickData[currentBeatIndex];
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

  void resetPlayers() {
    playerPool.clear();
    layerPlayersPool.resetAll();
    activeLayerHandles.clear();
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
    return '$pathName/${fileName}_${section.userTempo ?? section.defaultTempo}_$layer.$audioFormat';
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

  Future<void> setSectionLayersPlayerPool(Section section) async {
    //set global layers for the whole playlist
    final handleLoadLayerFiles =
        <Future>[]; //set of tasks running at the same time
    final playerPools = <LayerPlayer>[];
    final sectionLayers = <SectionLayer>[];

    //initialize player if for some reason it's not
    if (!player.isInitialized) {
      await player.init();
    }

    Future<void> setLayerPlayerPool(
        String filePath, String audioFileName, String layer) async {
      try {
        final audioSource = await player.loadFile(filePath);
        playerPools.add(
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

    Future<void> loadAudioFiles(SectionLayer sectionLayer) async {
      final String audioFileName = getAudioFileNAme(sectionLayer.audioUrl);
      log('audioFileName: $audioFileName, audioUrl: ${sectionLayer.audioUrl}');

      final file = await persistentController.readAudioFile(
          sessionScore!.id, audioFileName, sectionLayer.audioUrl);
      await setLayerPlayerPool(file.path, audioFileName, sectionLayer.layer);
    }

    for (final layer in section.layers!) {
      sectionLayers.add(SectionLayer(
          layer: layer, audioUrl: getAudioLayerUrl(section, layer)));
    }

    //getting section layer audio files
    for (final sectionLayer in sectionLayers) {
      handleLoadLayerFiles.add(loadAudioFiles(sectionLayer));
    }

    await Future.wait(handleLoadLayerFiles);

    void addPlayerPool() {
      // log('adding player pool, ${sectionLayers.toString()}');
      final layerPlayerPool = LayerPlayerPool(
          sectionIndex: section.sectionIndex,
          sectionKey: section.key,
          layers: sectionLayers,
          players: playerPools);
      //order pool
      layerPlayersPool.globalPools.add(layerPlayerPool);
    }

    addPlayerPool();
  }

  void setDefaultTempos() {
    lastUsedTempo = currentSection?.defaultTempo ?? 0;
    currentTempo =
        currentSection?.userTempo ?? currentSection?.defaultTempo ?? 0;
  }

  //create array of AudioPlayers for all songs in playlist
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

  void setChannelVolume(String layerName, double value) {
    final pool = currentLayerPlayerPool;
    //find currently targeted pool player
    pool?.setChannelVolume(value, layerName);

    notifyListeners();
  }

  Future<void> setLayersEnabled(bool value) async {
    layersEnabled = value;
    log('layerFilesLoaded: $layerFilesLoaded, totalLayerFiles: $totalLayerFiles');
    if (totalLayerFiles == 0) {
      layerFilesLoading = true;
      for (Section section
          in playlist.where((section) => section.layers != null)) {
        //check if files are there already
        if (layerPlayersPool.globalPools.isNotEmpty &&
            layerPlayersPool.globalPools
                .any((element) => element.sectionKey == section.key)) {
          continue;
        } else {
          await setSectionLayersPlayerPool(section);
        }
      }
    }
    toggleDefaultToLayerPlayerVolume(layersEnabled);

    layerFilesLoading = false;
    notifyListeners();
  }

  void toggleDefaultToLayerPlayerVolume(bool value) {
    void setVolume(double volume) {
      if (isPlaying) {
        player.setVolume(activeHandle!, playerVolume);
        for (SoundHandle handle in activeLayerHandles) {
          player.setVolume(handle, volume);
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

  Future<void> playLayers() async {
    activeLayerHandles.clear();
    log('play layers');

    if (currentLayerPlayerPool != null) {
      for (final pool in currentLayerPlayerPool!.players) {
        pool.activeHandle = await player.play(pool.audioSource);
        player.setVolume(pool.activeHandle!, pool.playerVolume!);
      }
    }
  }

  void stopLayers() {
    if (currentLayerPlayerPool?.activeLayerHandles != null) {
      for (final SoundHandle handle
          in currentLayerPlayerPool!.activeLayerHandles) {
        player.stop(handle);
      }
    }
  }

  void play() async {
    ticker.stop();
    jumped = false;
    currentPosition = Duration.zero;
    notifyListeners();
    getDuration();
    setGlobalVolume(globalVolume);

    if (currentSection?.layers != null) {
      await playLayers();
    } else {
      stopLayers();
      layersEnabled = false;
    }

//set volume
    if (!layersEnabled) {
      setPlayerVolume(1);
    } else {
      setPlayerVolume(0);
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
    // positionSub = position.listen((position) {});
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
    await player.stop(activeHandle!);
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
      (element) => element.key == sectionKey,
    );
    // currentMovementIndex = sessionMovements
    //     .indexWhere((el) => el.movementKey == currentSection!.movementKey);
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
    final SectionPrefs sectionPrefs = SectionPrefs(
      sectionKey: currentSection!.key,
      defaultTempo: currentSection!.defaultTempo,
      userTempo: currentSection!.userTempo,
      autoContinue: currentSection!.autoContinue,
    );
    setAdjustedMarkerPosition();

    persistentController.updateSectionPrefs(
        currentSection!.scoreId, currentSection!.key, sectionPrefs);
    return currentSection!.autoContinue;
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
