import 'dart:developer';
import 'package:gphil/theme/dark_theme.dart';
import 'package:gphil/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  ThemeData _themeData = darkMode;

  ThemeProvider(bool dark) {
    _isDarkMode = dark;
    setDarkMode();
  }

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;
  bool get isDarkModeEnabled => _isDarkMode;

  //set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  //set dark mode
  setDarkMode() {
    if (_isDarkMode) {
      themeData = darkMode;
    }
  }

  Future saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode);
    log(prefs.getBool('isDarkMode').toString());
  }

  //toglle theme
  void toggleTheme() async {
    themeData = themeData == lightMode ? darkMode : lightMode;
    saveTheme();
  }
}
