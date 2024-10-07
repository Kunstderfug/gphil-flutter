import 'package:flutter/material.dart';
import 'package:gphil/screens/library_screen.dart';
import 'package:gphil/screens/score_screen.dart';
import 'package:gphil/screens/performance_screen.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  bool get isPerformanceScreen => _currentIndex == 1 ? true : false;
  bool get isScoreScreen => _currentIndex == 2 ? true : false;
  bool get isLibraryScreen => _currentIndex == 0 ? true : false;

  final _navigationScreens = <Map<String, Object>>[
    {
      'title': 'L I B R A R Y',
      'icon': Icons.library_books_rounded,
      'screen': const LibraryScreen()
    },
    {
      'title': 'P R A C T I C E',
      'icon': Icons.piano,
      'screen': const PerformanceScreen()
    },
    {'title': 'S C O R E', 'icon': Icons.piano, 'screen': const ScoreScreen()},
  ];

  List<Map<String, Object>> get navigationScreens => _navigationScreens;

  void setNavigationIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
