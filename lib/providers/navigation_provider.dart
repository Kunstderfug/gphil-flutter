import 'package:flutter/material.dart';
import 'package:gphil/screens/library_screen.dart';
import 'package:gphil/screens/playlist_screen.dart';
import 'package:gphil/screens/score_screen.dart';
import 'package:gphil/screens/song_screen.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final List<Map<String, Object>> _navigationScreens = [
    {
      'title': 'L I B R A R Y',
      'icon': Icons.library_books_rounded,
      'screen': const LibraryScreen()
    },
    {
      'title': 'P L A Y L I S T',
      'icon': Icons.playlist_play,
      'screen': const PlaylistScreen()
    },
    {
      'title': 'P E R F O R M A N C E',
      'icon': Icons.piano,
      'screen': const SongScreen()
    },
    {'title': 'S C O R E', 'icon': Icons.piano, 'screen': const ScoreScreen()},
  ];

  List<Map<String, Object>> get navigationScreens => _navigationScreens;

  void setNavigationIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
