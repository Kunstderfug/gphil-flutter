import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/sanity_service.dart';

class LibraryProvider extends ChangeNotifier {
  final List<LibraryItem> _library = [];
  final LibraryIndex _indexedLibrary = LibraryIndex(composers: []);
  String currentScoreId = '';
  String error = '';
  bool _isLoading = false;
  AppState appState = AppState.idle;
  Connectivity? connectivity;
  final p = PersistentDataController();

//!GETTERS
  List<LibraryItem> get library => _library;
  bool get isLoading => _isLoading;
  LibraryIndex get indexedLibrary => _indexedLibrary;

//!SETTERS
  set library(List<LibraryItem> library) {
    _library.clear();
    _library.addAll(library);
    notifyListeners();
  }

  set indexedLibrary(LibraryIndex libraryIndex) {
    indexedLibrary.composers.clear();
    indexedLibrary.composers.addAll(libraryIndex.composers);
    notifyListeners();
  }

  set isLoading(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  LibraryProvider() {
    getLibrary();
  }

  Future<List<LibraryItem>> getLibrary() async {
    isLoading = true;
    notifyListeners();
    final bool online = await p.isOnline();
    try {
      if (online) {
        log('fetching library');
        library = await SanityService().fetchLibrary();
        indexedLibrary = libraryIndex(library);
      } else {
        log('fetching local library');
        library = await p.getLocalLibrary();
        indexedLibrary = libraryIndex(library);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
    notifyListeners();
    return library;
  }

  void setScoreId(String scoreId) {
    currentScoreId = scoreId;
    notifyListeners();
  }
}

class LibraryIndex {
  List<Composer> composers;

  LibraryIndex({required this.composers});
}

class Composer {
  String name;
  List<LibraryItem> scores;

  Composer({required this.name, required this.scores});
}

LibraryIndex libraryIndex(List<LibraryItem> library) {
  List<Composer> composers = [];
  for (LibraryItem score in library) {
    String composer = score.composer;
    int index = composers.indexWhere((c) => c.name == composer);

    if (index == -1) {
      composers.add(Composer(name: composer, scores: [score]));
    } else {
      composers[index].scores.add(score);
    }
  }

  return LibraryIndex(composers: composers);
}
