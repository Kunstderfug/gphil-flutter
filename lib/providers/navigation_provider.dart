import 'package:flutter/material.dart';
import 'package:gphil/screens/library_screen.dart';
import 'package:gphil/screens/score_screen.dart';
import 'package:gphil/screens/performance_screen.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final _navigationScreens = <Map<String, Object>>[
    {
      'title': 'L I B R A R Y',
      'icon': Icons.library_books_rounded,
      'screen': const LibraryScreen()
    },
    {
      'title': 'P E R F O R M A N C E',
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
