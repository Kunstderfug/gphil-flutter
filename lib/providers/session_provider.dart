import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/section.dart';

class SessionMovement {
  final String title;
  final int index;

  SessionMovement(this.title, this.index);
}

class SessionProvider extends ChangeNotifier {
  List<Section> _sessionPlaylist = [];
  Score? _sessionScore;
  List<SessionMovement> _sessionMovements = [];
  bool _movementExistInSession = false;

  bool get movementExistInSession => _movementExistInSession;
  List<Section> get sessionPlaylist => _sessionPlaylist;
  Score? get sessionScore => _sessionScore;
  String get sessionComposer => _sessionScore?.composer ?? '';
  List<SessionMovement> get sessionMovements => _sessionMovements;
  bool get playlistIsEmpty => sessionPlaylist.isEmpty;

  set sessionComposer(String? value) {
    sessionComposer = value;
    notifyListeners();
  }

  set sessionScore(Score? value) {
    _sessionScore = value;
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
    sessionScore = null;
    notifyListeners();
  }

  //check if a movement sections are all in the sessionPlaylist
  bool containsMovement(Movement movement) {
    return movement.setupSections.every((section) =>
        sessionPlaylist.any((element) => element.key == section.key));
  }

  void addMovement(Score score, Movement movement) {
    for (final section in movement.setupSections) {
      //check if section already exists in session
      if (sessionPlaylist.any((element) => element.key == section.key)) {
        continue;
      } else {
        sessionPlaylist.add(section);
        section.sectionIndex = sessionPlaylist.indexOf(section);
        sessionScore = score;
      }
    }
    sessionPlaylist.sort((a, b) => a.movementIndex.compareTo(b.movementIndex));
    movementExistInSession = containsMovement(movement);

    sessionMovements.add(SessionMovement(movement.title, movement.index));
    sessionMovements.sort((a, b) => a.index.compareTo(b.index));

    notifyListeners();
    log('session playlist length: ${sessionPlaylist.length}');
    log('sections movementIndex: ${sessionPlaylist.map((section) => section.movementIndex).toList()}');
  }

  void removeMovement(Movement movement) {
    for (final section in movement.setupSections) {
      sessionPlaylist.removeWhere((element) => element.key == section.key);
    }

    sessionMovements
        .removeWhere((SessionMovement item) => item.index == movement.index);
    sessionMovements.sort((a, b) => a.index.compareTo(b.index));
    if (sessionPlaylist.isEmpty) {
      sessionScore = null;
    }
    notifyListeners();
    log('session playlist length: ${sessionPlaylist.length}');
  }

  void startSession() {
    notifyListeners();
  }
}
