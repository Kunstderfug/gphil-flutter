import 'package:flutter/material.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';

final playlistProvider = PlaylistProvider();
final scoreProvider = ScoreProvider();
final navigation = NavigationProvider();
final persistentController = PersistentDataController();

class SessionProvider extends ChangeNotifier {
  List<Section> _sessionPlaylist = [];
  // Score? _sessionScore;
  List<SessionMovement> _sessionMovements = [];
  bool _movementExistInSession = false;
  int movementIndex = 0;
  int sectionIndex = 0;
  // final List<SectionClickData> _sessionClickData = [];
  bool showPrompt = false;
  Movement? movementToAdd;
  SessionMovement? currentMovement;
  String currentMovementKey = '';
  String currentSectionKey = '';

  bool get movementExistInSession => _movementExistInSession;
  List<Section> get sessionPlaylist => _sessionPlaylist;
  // Score? get sessionScore => _sessionScore;
  // String get sessionComposer => _sessionScore?.composer ?? '';
  List<SessionMovement> get sessionMovements => _sessionMovements;
  // List<SectionClickData>? get sessionClickData => _sessionClickData;
  // SectionClickData? get currentClick => _sessionClickData.isNotEmpty
  //     ? _sessionClickData.firstWhere(
  //         (click) => click.sectionKey == sessionPlaylist[sectionIndex].key)
  //     : null;

  bool get playlistIsEmpty => sessionPlaylist.isEmpty;

  set sessionComposer(String? value) {
    sessionComposer = value;
    notifyListeners();
  }

  // set sessionScore(Score? value) {
  //   sessionScore = value;
  //   notifyListeners();
  // }

  set sessionMovements(List<SessionMovement> value) {
    _sessionMovements = value;
    notifyListeners();
  }

  set sessionPlaylist(List<Section> value) {
    _sessionPlaylist = value;
    notifyListeners();
  }

  set movementExistInSession(bool value) {
    _movementExistInSession = value;
    notifyListeners();
  }

  void clearSession() {
    sessionPlaylist.clear();
    sessionMovements.clear();
    // sessionScore = null;
    showPrompt = false;
    notifyListeners();
  }

  //check if a movement sections are all in the sessionPlaylist

  void setMovementIndex(int index) {
    movementIndex = index;
    notifyListeners();
  }

  // void setMovementIndexByKey(String movementKey) {
  //   currentMovementKey = movementKey;
  //   sectionIndex = sessionPlaylist.indexWhere(
  //     (element) => element.movementKey == movementKey,
  //   );
  //   log('sectionIndex: $sectionIndex');
  //   log('movementKey: $currentMovementKey, currentMovementKey: ${currentMovement?.movementKey}');
  // }

  // void setCurrentSectionByKey(String sectionKey) {
  //   sectionIndex = sessionPlaylist.indexWhere(
  //     (element) => element.key == sectionKey,
  //   );
  //   currentSectionKey = sectionKey;
  //   currentMovementKey = sessionPlaylist[sectionIndex].movementKey;
  //   currentMovement = sessionMovements.firstWhere(
  //     (element) => element.movementKey == currentMovementKey,
  //   );
  //   movementIndex = sessionPlaylist[sectionIndex].movementIndex;
  // }

  void setSectionIndex(int index) {
    sectionIndex = index;
  }
}
