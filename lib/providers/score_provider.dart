// import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/score_user_prefs.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/services/sanity_service.dart';
import 'package:gphil/services/supabase_service.dart';

final String supabaseUrl = SupabaseService().supabaseUrl;
const String format = 'mp3';
final persistentController = PersistentDataController();

class ScoreProvider extends ChangeNotifier {
  late String _currentScoreId;
  int _movementIndex = 0;
  int _sectionIndex = 0;
  int _currentTempo = 0;
  late int? _userTempo;
  Score? _currentScore;
  late Movement _currentMovement;
  late List<Section> _currentSections;
  late Section _currentSection;
  bool isLoading = false;
  String error = '';
  String? _sectionImageUrl;
  File? _sectionImageFile;

// GETTERS
  String get scoreId => _currentScoreId;
  int get movementIndex => _movementIndex;
  int get sectionIndex => _sectionIndex;
  int get currentTempo => _currentTempo;
  int? get userTempo => _userTempo;
  Score? get currentScore => _currentScore;
  List<Movement> get currentMovements => _currentScore!.setupMovements;
  List<Section> get currentSections => _currentSections;
  Section get currentSection => _currentSection;
  Movement get currentMovement => _currentMovement;
  String? get sectionImageUrl => _sectionImageUrl;
  File? get sectionImageFile => _sectionImageFile;

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

  //METHODS
  void setMovementIndex(int index) async {
    movementIndex = index;
    setCurrentMovement(index);
    setCurrentSections();
    await setCurrentSection(0);
  }

  void setCurrentMovement(int index) {
    currentMovement = _currentScore!.setupMovements[index];
  }

  void setCurrentSections() {
    currentSections = _currentMovement.setupSections;
  }

  Future<Section> setCurrentSection(int index) async {
    sectionIndex = index;
    currentSection = _currentSections[index];
    currentTempo = currentSection.defaultTempo;

    //read from persistent storage
    final data = await persistentController.readJsonFile(
        currentScore!.id, currentSection.key);

    final currentPrefs = data != null ? SectionPrefs.fromJson(data) : null;

    if (currentPrefs != null) {
      currentSection.userTempo = currentPrefs.userTempo;
      userTempo = currentPrefs.userTempo;
      currentMovement.setupSections[sectionIndex] = currentSection;
      currentSections = _currentSections;
    }

    //write to persistent storage
    final sectionPrefs = SectionPrefs(
        sectionKey: currentSection.key,
        defaultTempo: currentTempo,
        userTempo: currentSection.userTempo);

    try {
      await persistentController.writeJsonFile(
          currentScore!.id, currentSection.key, sectionPrefs);

      if (currentSection.sectionImage != null) {
        sectionImageFile = null;
        sectionImageUrl = null;
        String imageUrl =
            SanityService().getImageUrl(currentSection.sectionImage!.asset.ref);
        String imageRef = currentSection.sectionImage!.asset.ref;
        final imageFile = await persistentController.readImageFile(
            scoreId, imageUrl, imageRef);
        sectionImageUrl = imageFile?.path;
        sectionImageFile = imageFile;
      }
    } catch (e) {
      error = e.toString();
    }

    return currentSection;
  }

  void setCurrentTempo(int tempo) async {
    currentSection.userTempo = tempo;
    currentTempo = tempo;
    userTempo = tempo;

    //update sections array with new data
    currentMovement.setupSections[sectionIndex] = currentSection;
    currentSections = _currentSections;

    final sectionPrefs = SectionPrefs(
        sectionKey: currentSection.key,
        defaultTempo: currentSection.defaultTempo,
        userTempo: tempo);

    try {
      await persistentController.writeJsonFile(
          currentScore!.id, currentSection.key, sectionPrefs);
    } catch (e) {
      error = e.toString();
    }
  }

  Future<void> getScore() async {
    // currentScore = null;
    try {
      isLoading = true;
      InitScore? score = await SanityService().fetchScore(_currentScoreId);

      if (score == null) {
        error = 'No score found';
        return;
      }
      currentScore = setupScore(score);
      scoreId = score.id;
      setMovementIndex(0);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  Score setupScore(InitScore score) {
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
    );

    for (InitMovement movement in score.movements) {
      Movement newMovement = Movement(
          score: movement.score,
          title: movement.title,
          key: movement.key,
          index: movement.index,
          sections: movement.sections,
          setupSections: []);
      for (InitSection section in newMovement.sections) {
        Section newSection = Section(
          sectionIndex: newMovement.sections.indexOf(section),
          name: section.name,
          tempoRangeFull: section.tempoRangeFull,
          step: section.step,
          movementIndex: movement.index,
          key: section.key,
          fileList: [],
          tempoRange: [],
          defaultTempo: section.defaultTempo,
          sectionImage: section.sectionImage,
        );

        newSection.tempoRange =
            setTempoRange(section.tempoRangeFull, section.step);

        newSection.fileList = setFileList(
          score.slug,
          score.pathName,
          section.movementIndex,
          newSection.tempoRange,
          section.name,
          AudioFormat.mp3,
        );

        newMovement.setupSections.add(newSection);
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
}

class AudioFormat {
  static const String mp3 = 'mp3';
  static const String opus = 'opus';
  static const String flac = 'flac';
}
