import 'dart:developer';

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
  late String _scoreId;
  int _movementIndex = 0;
  int _sectionIndex = 0;
  int _currentTempo = 0;
  late int? _userTempo;
  SetupScore? _currentScore;
  late SetupMovement _currentMovement;
  late List<SetupSection> _currentSections;
  late SetupSection _currentSection;
  bool isLoading = false;
  String error = '';
  String? _sectionImageUrl;

// GETTERS
  String get scoreId => _scoreId;
  int get movementIndex => _movementIndex;
  int get sectionIndex => _sectionIndex;
  int get currentTempo => _currentTempo;
  int? get userTempo => _userTempo;
  SetupScore? get currentScore => _currentScore;
  List<SetupMovement> get currentMovements => _currentScore!.setupMovements;
  List<SetupSection> get currentSections => _currentSections;
  SetupSection get currentSection => _currentSection;
  SetupMovement get currentMovement => _currentMovement;

// SETTERS
  set scoreId(String value) {
    _scoreId = value;
    notifyListeners();
  }

  set currentScore(SetupScore? value) {
    _currentScore = value;
    notifyListeners();
  }

  set currentMovement(SetupMovement value) {
    _currentMovement = value;
    notifyListeners();
  }

  set currentSections(List<SetupSection> value) {
    _currentSections = value;
    notifyListeners();
  }

  set currentSection(SetupSection value) {
    _currentSection = value;
    notifyListeners();
  }

  set sectionImageUrl(String? value) {
    _sectionImageUrl = value;
    log(_sectionImageUrl.toString());
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
  void setMovementIndex(int index) {
    movementIndex = index;
    setCurrentMovement(index);
    setCurrentSections();
    setCurrentSection(0);
  }

  void setCurrentMovement(int index) {
    currentMovement = _currentScore!.setupMovements[index];
  }

  void setCurrentSections() {
    currentSections = _currentMovement.setupSections;
  }

  void setCurrentSection(int index) async {
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
    }

    //write to persistent storage
    final sectionPrefs = SectionPrefs(
        sectionKey: currentSection.key,
        defaultTempo: currentTempo,
        userTempo: currentSection.userTempo);

    try {
      await persistentController.writeJsonFile(
          currentScore!.id, currentSection.key, sectionPrefs);
    } catch (e) {
      error = e.toString();
    }
  }

  void setCurrentTempo(int tempo) async {
    currentSection.userTempo = tempo;
    currentTempo = tempo;
    userTempo = tempo;

    //update sections array with new data
    _currentSections[sectionIndex] = currentSection;
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
      Score? score = await SanityService().fetchScore(_scoreId);

      if (score == null) {
        error = 'No score found';
        return;
      }
      currentScore = setupScore(score);
      setMovementIndex(0);
    } catch (e) {
      error = e.toString();
      log('score provider: $error');
    } finally {
      isLoading = false;
    }
  }

  SetupScore setupScore(Score score) {
    SetupScore newScore = SetupScore(
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

    for (Movement movement in score.movements) {
      SetupMovement newMovement = SetupMovement(
          score: movement.score,
          title: movement.title,
          key: movement.key,
          index: movement.index,
          sections: movement.sections,
          setupSections: []);
      for (Section section in newMovement.sections) {
        SetupSection newSection = SetupSection(
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
  static const String ogg = 'opus';
}
