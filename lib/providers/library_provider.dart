import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/sanity_service.dart';
// Import SharedPreferences
import 'package:shared_preferences/shared_preferences.dart';

class LibraryProvider extends ChangeNotifier {
  final List<LibraryItem> _library = [];
  final LibraryIndex _indexedLibrary = LibraryIndex(composers: []);
  String currentScoreId = '';
  String error = '';
  bool _isLoading = false;
  AppState appState = AppState.idle;
  Connectivity? connectivity;
  final p = PersistentDataController();
  // recent scores
  final List<LibraryItem> _recentlyAccessedItems = [];
  final List<LibraryItem> _recentlyUpdatedItems = [];

  // Call loadRecentlyAccessedItems in the constructor
  LibraryProvider() {
    getLibrary();
  }

//!GETTERS

  List<LibraryItem> get library => _library;
  bool get isLoading => _isLoading;
  LibraryIndex get indexedLibrary => _indexedLibrary;
  List<LibraryItem> get recentlyAccessedItems => _recentlyAccessedItems;
  List<LibraryItem> get recentlyUpdatedItems => _recentlyUpdatedItems;
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

  Future<List<LibraryItem>> getLibrary() async {
    isLoading = true;
    notifyListeners();
    final bool online = await p.isOnline();
    try {
      if (online) {
        log('fetching library');
        library = await SanityService().fetchLibrary();
        indexedLibrary = libraryIndex(library);
        getRecentlyUpdatedItems(library);
        loadRecentlyAccessedItems(library);
      } else {
        log('fetching local library');
        library = await p.getLocalLibrary();
        indexedLibrary = libraryIndex(library);
        loadRecentlyAccessedItems(library);
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

  Future<void> addToRecentlyAccessed(LibraryItem score) async {
    // Remove the score if it's already in the list
    _recentlyAccessedItems.remove(score);

    // Add the score to the beginning of the list
    _recentlyAccessedItems.insert(0, score);

    // Keep only the 5 most recent items
    if (_recentlyAccessedItems.length > 5) {
      _recentlyAccessedItems.removeRange(5, _recentlyAccessedItems.length);
    }

    await saveRecentlyAccessedItems(_recentlyAccessedItems);

    notifyListeners();
  }

  List<LibraryItem> getRecentlyUpdatedItems(List<LibraryItem> items) {
    List<LibraryItem> sortedItems = List.from(items);
    sortedItems.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    _recentlyUpdatedItems.clear();
    _recentlyUpdatedItems.addAll(sortedItems.take(5).toList());
    return _recentlyUpdatedItems;
  }

  // Method to load recently accessed items from SharedPreferences
  Future<void> loadRecentlyAccessedItems(List<LibraryItem> libraryItems) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? items = prefs.getStringList('recentlyAccessedItems');
    if (items != null && items.isNotEmpty) {
      _recentlyAccessedItems.clear();

      _recentlyAccessedItems.addAll(items.map(
          (item) => libraryItems.firstWhere((element) => element.id == item)));
      notifyListeners();
    }
  }

  // Method to save recently accessed items to SharedPreferences
  Future<void> saveRecentlyAccessedItems(List<LibraryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ids =
        _recentlyAccessedItems.map((item) => item.id).toList();
    log('saving recently accessed items: $ids');
    await prefs.setStringList('recentlyAccessedItems', ids);
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
