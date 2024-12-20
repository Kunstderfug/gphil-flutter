import 'package:flutter/material.dart';
import 'package:gphil/screens/admin_screen.dart';
import 'package:gphil/screens/help_screen.dart';
import 'package:gphil/screens/library_screen.dart';
import 'package:gphil/screens/score_screen.dart';
import 'package:gphil/screens/performance_screen.dart';

class NavigationScreen {
  final String title;
  final IconData icon;
  final Widget screen;

  const NavigationScreen(
      {required this.title, required this.icon, required this.screen});
}

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _selectedIndex = 0;

  int get currentIndex => _currentIndex;
  int get selectedIndex => _selectedIndex;
  bool get isPerformanceScreen => _currentIndex == 1 ? true : false;
  bool get isScoreScreen => _currentIndex == 2 ? true : false;
  bool get isLibraryScreen => _currentIndex == 0 ? true : false;
  bool get isHelpScreen => _currentIndex == 3 ? true : false;
  bool get isAdminScreen => _currentIndex == 4 ? true : false;
  List<NavigationScreen> get navigationScreens => _navigationScreens;

  final _navigationScreens = <NavigationScreen>[
    NavigationScreen(
        title: 'L I B R A R Y',
        icon: Icons.library_books,
        screen: const LibraryScreen()),
    NavigationScreen(
        title: 'P R A C T I C E',
        icon: Icons.piano_sharp,
        screen: const PerformanceScreen()),
    NavigationScreen(
        title: 'S C O R E',
        icon: Icons.book_sharp,
        screen: const ScoreScreen()),
    NavigationScreen(
        title: 'H E L P', icon: Icons.help_sharp, screen: const HelpScreen()),
    NavigationScreen(
        title: 'A D M I N',
        icon: Icons.settings_outlined,
        screen: const AdminScreen()),
  ];

  void setNavigationIndex(int index) {
    _currentIndex = index;
    _selectedIndex = index;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setScoreScreen() {
    setCurrentIndex(2);
    setSelectedIndex(0);
  }
}
