import 'package:flutter/material.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/models/section.dart';

final p = PersistentDataController();

class SessionProvider extends ChangeNotifier {
  List<Section> _sessionPlaylist = [];
  List<SessionMovement> _sessionMovements = [];
  bool _movementExistInSession = false;
  int movementIndex = 0;
  int sectionIndex = 0;
  bool showPrompt = false;
  Movement? movementToAdd;
  SessionMovement? currentMovement;
  String currentMovementKey = '';
  String currentSectionKey = '';

  bool get movementExistInSession => _movementExistInSession;
  List<Section> get sessionPlaylist => _sessionPlaylist;

  List<SessionMovement> get sessionMovements => _sessionMovements;

  bool get playlistIsEmpty => sessionPlaylist.isEmpty;

  set sessionComposer(String? value) {
    sessionComposer = value;
    notifyListeners();
  }

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

  void setMovementIndex(int index) {
    movementIndex = index;
    notifyListeners();
  }

  void setSectionIndex(int index) {
    sectionIndex = index;
  }
}
