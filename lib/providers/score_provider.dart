import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/services/supabase_service.dart';
import 'package:signals/signals.dart';

enum AudioFormats { mp3, flac, opus }

final String supabaseUrl = SupabaseService().supabaseUrl;
const String audioFormat = AudioFormat.mp3;
final persistentController = PersistentDataController();

class ScoreProvider extends ChangeNotifier {
  late String _currentScoreId;
  String currentScoreRev = '';
  int _movementIndex = 0;
  int _sectionIndex = 0;
  int _currentTempo = 0;
  int? _userTempo = 0;
  Score? _currentScore;
  late Movement _currentMovement;
  late List<Section> _currentSections;
  late Section _currentSection;
  String sectionKey = '';
  String error = '';
  String? _sectionImageUrl;
  List<ClickData>? _sectionClickData;
  File? _sectionImageFile;
  // bool _scoreIsUptoDate = false;
  double _progressDownload = 0;
  bool isLoading = false;
  bool _scoreIsUptoDate = false;

// GETTERS
  String get scoreId => _currentScoreId;
  int get movementIndex => _movementIndex;
  int get sectionIndex => _sectionIndex;
  int get currentTempo => _currentTempo;
  int get tempoIndex => currentSection.tempoRange.indexOf(currentTempo);
  String get audioUrl => currentSection.fileList[tempoIndex];
  int? get userTempo => _userTempo;
  Score? get currentScore => _currentScore;
  List<Movement> get currentMovements => _currentScore!.setupMovements;
  List<Section> get currentSections => _currentSections;
  Section get currentSection => _currentSection;
  Movement get currentMovement => _currentMovement;
  String? get sectionImageUrl => _sectionImageUrl;
  File? get sectionImageFile => _sectionImageFile;
  List<ClickData>? get sectionClickData => _sectionClickData;
  String get scoreRev => currentScore?.rev ?? '';
  double get progressDownload => _progressDownload;
  bool get scoreIsUptoDate => _scoreIsUptoDate;

// SETTERS
  set scoreId(String value) {
    _currentScoreId = value;
    notifyListeners();
  }

  set currentScore(Score? value) {
    _currentScore = value;
    notifyListeners();
  }

  set currentMovement(Movement value) {
    _currentMovement = value;
    notifyListeners();
  }

  set currentSections(List<Section> value) {
    _currentSections = value;
    notifyListeners();
  }

  set currentSection(Section value) {
    _currentSection = value;
    sectionKey = value.key;
    notifyListeners();
  }

  set sectionImageUrl(String? value) {
    _sectionImageUrl = value;
    notifyListeners();
  }

  set sectionImageFile(File? value) {
    _sectionImageFile = value;
    notifyListeners();
  }

  set movementIndex(int value) {
    _movementIndex = value;
    notifyListeners();
  }

  set sectionIndex(int value) {
    _sectionIndex = value;
    notifyListeners();
  }

  set currentTempo(int value) {
    _currentTempo = value;
    notifyListeners();
  }

  set userTempo(int? value) {
    _userTempo = value;
    notifyListeners();
  }

  set sectionClickData(List<ClickData>? value) {
    _sectionClickData = value;
    notifyListeners();
  }

  set progressDownload(double value) {
    _progressDownload = value;
    notifyListeners();
  }

  set scoreIsUptoDate(bool value) {
    _scoreIsUptoDate = value;
    notifyListeners();
  }

  //METHODS

  void setCurrentScoreIdAndRevision(String id, String rev) {
    _currentScoreId = id;
    currentScoreRev = rev;
  }

  void setMovementIndex(int index) async {
    movementIndex = index;
    _currentMovement = _currentScore!.setupMovements[movementIndex];
    setCurrentSections();
    await setCurrentSection(currentSections.first.key);
  }

  void setCurrentMovement(String key) {
    _currentMovement = _currentScore!.setupMovements
        .firstWhere((movement) => movement.key == key);
  }

  void setCurrentSections() {
    currentSections = _currentMovement.setupSections;
  }

  void setCurrentSectionByKey(String movementKey, String sectionKey) async {
    setCurrentMovement(movementKey);
    _movementIndex = _currentScore!.setupMovements
        .indexWhere((element) => element.key == movementKey);
    _currentSections = currentMovement.setupSections;
    _currentSection =
        _currentSections.firstWhere((section) => section.key == sectionKey);
    if (_currentSection.sectionImage != null) {
      await setImageFle();
    }
  }

  Future<SectionPrefs?> getSectionPrefs(
      String scoreId, String sectionKey) async {
    final sectionUserPref =
        await persistentController.readSectionJsonFile(scoreId, sectionKey);

    final currentPrefs =
        sectionUserPref != null ? SectionPrefs.fromJson(sectionUserPref) : null;

    return currentPrefs;
  }

  Future<void> updateSectionFromLocalPrefs(
      SectionPrefs sectionPrefs, Section section) async {
    section.userTempo = sectionPrefs.userTempo;
    section.userLayerTempo = sectionPrefs.userLayerTempo;
    section.autoContinue = sectionPrefs.autoContinue;
    section.sectionVolume = sectionPrefs.sectionVolume;
    section.muted = sectionPrefs.muted ?? false;
    log('updateSectionFromLocalPrefs, ${section.autoContinue}');
  }

  void setSections(String movementKey, String sectionKey) {
    setCurrentMovement(movementKey);
    setCurrentSections();
  }

  Future<Section> setCurrentSection(String sectionKey) async {
    sectionIndex =
        _currentSections.indexWhere((section) => section.key == sectionKey);
    currentSection =
        _currentSections.firstWhere((section) => section.key == sectionKey);
    currentSignalSection.value = currentSection;
    currentTempo = currentSection.defaultTempo;

    //read from persistent storage

    final clickData = await persistentController.readClickJsonFile(
        currentScore!.id, currentSection.key, currentSection.clickDataUrl!);
    sectionClickData = clickData;

    final currentPrefs =
        await getSectionPrefs(currentScore!.id, currentSection.key);

    if (currentPrefs != null) {
      currentSection.userTempo = currentPrefs.userTempo;
      userTempo = currentPrefs.userTempo;
      currentSection.autoContinue = currentPrefs.autoContinue;
      currentMovement.setupSections[sectionIndex] = currentSection;
      currentSections = _currentSections;
      log('setCurrentSection, ${currentSection.autoContinue}');
    } else {
      //write to persistent storage
      final sectionPrefs = SectionPrefs(
          sectionKey: currentSection.key,
          defaultTempo: currentTempo,
          userTempo: currentSection.userTempo,
          autoContinue: currentSection.autoContinue);

      try {
        await persistentController.writeSectionJsonFile(
            currentScore!.id, currentSection.key, sectionPrefs);
      } catch (e) {
        error = e.toString();
      }
    }
    if (currentSection.sectionImage != null) {
      await setImageFle();
    }

    return currentSection;
  }

  Future<File?> setImageFle() async {
    sectionImageFile = null;
    sectionImageUrl = null;
    final imageFile = await persistentController.readImageFile(
        scoreId, currentSection.sectionImage!.asset.ref);
    sectionImageUrl = imageFile?.path;
    sectionImageFile = imageFile;
    return imageFile;
  }

  void setCurrentTempo(int tempo) async {
    currentSection.userTempo = tempo;

    currentTempo = tempo;
    userTempo = tempo;

    final int? layerTempoIndex =
        currentSection.tempoRangeLayers?.indexOf(tempo);
    layerTempoIndex != -1 && layerTempoIndex != null
        ? currentSection.userLayerTempo = tempo
        : null;

    final String audioFileName = audioUrl.split('/').last;

    //update sections array with new data
    currentMovement.setupSections[sectionIndex] = currentSection;
    currentSections = _currentSections;

    final sectionPrefs = SectionPrefs(
      sectionKey: currentSection.key,
      defaultTempo: currentSection.defaultTempo,
      userTempo: tempo,
      userLayerTempo:
          layerTempoIndex != -1 ? tempo : currentSection.defaultTempo,
      autoContinue: currentSection.autoContinue,
    );

    try {
      await persistentController.writeSectionJsonFile(
          currentScore!.id, currentSection.key, sectionPrefs);
      await persistentController.readAudioFile(
          scoreId, audioFileName, audioUrl);
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> getScore(String scoreId) async {
    if (_currentScore?.id == scoreId) {
      return;
    }
    _movementIndex = 0;
    try {
      error = '';
      isLoading = true;
      InitScore? score = await persistentController.readScoreData(scoreId);

      if (score == null) {
        error = 'No score found';
        return;
      }
      currentScore = await setupScore(score);
      currentSignalScore.value = currentScore;

      // scoreId = currentScore!.id;

      //check score revision
      scoreIsUptoDate = await persistentController.checkScoreRevision(
          scoreId, currentScoreRev);

      //set movement index
      setMovementIndex(_movementIndex);
    } catch (e) {
      log(e.toString());
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  Future<void> updateCurrentScore() async {
    await persistentController.updateScore(_currentScoreId, currentScoreRev);
    await persistentController.writeScoreRevision(scoreId, currentScoreRev);
    InitScore? score =
        await persistentController.readScoreData(_currentScoreId);
    currentScore = await setupScore(score!);
    currentSignalScore.value = currentScore;
    setMovementIndex(_movementIndex);

    scoreIsUptoDate =
        await persistentController.checkScoreRevision(scoreId, currentScoreRev);
  }

  Future<Score> setupScore(InitScore score) async {
    int index = 0;

    Score newScore = Score(
        shortTitle: score.shortTitle,
        slug: score.slug,
        pathName: score.pathName,
        movements: score.movements,
        updatedAt: score.updatedAt,
        rev: score.rev,
        id: score.id,
        composer: score.composer,
        setupMovements: [],
        fullScoreUrl: score.fullScoreUrl,
        pianoScoreUrl: score.pianoScoreUrl,
        globalLayers: score.globalLayers);

    for (InitMovement movement in score.movements) {
      Movement newMovement = Movement(
          score: movement.score,
          title: movement.title,
          key: movement.key,
          index: movement.index,
          sections: movement.sections,
          renderTail: movement.renderTail,
          setupSections: []);
      for (InitSection section in newMovement.sections) {
        Section newSection = Section(
            scoreId: newMovement.score.ref,
            movementKey: newMovement.key,
            sectionIndex: index,
            name: section.name,
            tempoRangeFull: section.tempoRangeFull,
            layerStep: section.layerStep,
            tempoRangeLayers: section.tempoRangeLayers != null &&
                    section.layerStep != null
                ? setTempoRange(section.tempoRangeLayers!, section.layerStep!)
                : [],
            step: section.step,
            movementIndex: movement.index,
            key: section.key,
            fileList: [],
            tempoRange: [],
            metronomeAvailable: section.metronomeAvailable,
            defaultTempo: section.defaultTempo,
            sectionImage: section.sectionImage,
            autoContinue: section.autoContinue,
            autoContinueMarker: section.autoContinueMarker,
            defaultSectionLength: section.defaultSectionLength,
            beatsPerBar: section.beatsPerBar,
            beatLength: section.beatLength,
            tempoMultiplier: section.tempoMultiplier,
            layers: section.layers,
            muted: false,
            clickDataUrl: getClickDataUrl(
                score.slug,
                score.pathName,
                section.movementIndex,
                section.name,
                section.tempoMultiplier != null
                    ? section.defaultTempo * section.tempoMultiplier!
                    : section.defaultTempo));

        newSection.tempoRange =
            setTempoRange(section.tempoRangeFull, section.step);

        newSection.fileList = setFileList(
          score.slug,
          score.pathName,
          section.movementIndex,
          section.tempoMultiplier == null
              ? newSection.tempoRange
              : newSection.tempoRange
                  .map((int tempo) => tempo * section.tempoMultiplier!)
                  .toList(),
          section.name,
          AudioFormat.mp3,
        );

        final SectionPrefs? localPrefs =
            await getSectionPrefs(newSection.scoreId, newSection.key);
        if (localPrefs != null) {
          await updateSectionFromLocalPrefs(localPrefs, newSection);
        } else {
          log('local prefs not found');
        }
        newMovement.setupSections.add(newSection);
        newMovement.sections = [];

        index++;
      }

      newScore.setupMovements.add(newMovement);
    }

    newScore.movements = [];

    return newScore;
  }

  List<int> setTempoRange(List<int> data, int step) {
    List<int> array = [];
    for (int i = data[0]; i <= data[1]; i += step) {
      array.add(i);
    }
    return array;
  }

  List<String> setFileList(
    String slug,
    String pathName,
    int movementIndex,
    List<int> tempoRange,
    String sectionName,
    String format,
  ) {
    String fullPath = '$supabaseUrl$slug/$movementIndex/$sectionName';
    String fullName = '${pathName}_${movementIndex}_$sectionName';
    return tempoRange
        .map((tempo) => '$fullPath/${fullName}_$tempo.$format')
        .toList();
  }

  //save audio files
  Future<void> saveAudioFiles(List<Section> sections) async {
    progressDownload = 0;
    final audioFilesUrls = [];
    final requests = <Future>[];
    int totalFiles = 0;

    for (Section section in sections) {
      for (String audioUrl in section.fileList) {
        audioFilesUrls.add(audioUrl);
      }
    }
    Future<void> readAndCheckProgress(
        String audioUrl, String audioFileName) async {
      final bytes = await persistentController.readAudioFile(
          scoreId, audioFileName, audioUrl);
      if (bytes.bytes.isNotEmpty) totalFiles++;
      progressDownload = totalFiles / audioFilesUrls.length;
      progressDownload == 1 ? progressDownload = 0 : progressDownload;
    }

    for (final audioUrl in audioFilesUrls) {
      final String audioFileName = audioUrl.split('/').last;
      requests.add(readAndCheckProgress(audioUrl, audioFileName));
    }

    await Future.wait(requests);
  }
}

//get click data url
String getClickDataUrl(String slug, String pathName, int movementIndex,
    String sectionName, int tempo) {
  String fullPath = '$supabaseUrl$slug/$movementIndex/CLICKDATA';
  String fileName = '${pathName}_${movementIndex}_${sectionName}_$tempo';
  return '$fullPath/$fileName.json';
}

class AudioFormat {
  static const String mp3 = 'mp3';
  static const String opus = 'opus';
  static const String flac = 'flac';
}

//TEST SIGNALS
Signal<Score?> currentSignalScore = signal(null);
Signal<Section?> currentSignalSection = signal(null);
final currentScoreId = computed(() => currentSignalScore.value?.id);
final currentScoreTitle = computed(() => currentSignalScore.value?.shortTitle);
final currentSectionKey = computed(() => currentSignalSection.value?.key);
