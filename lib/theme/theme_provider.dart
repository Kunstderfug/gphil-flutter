import 'package:gphil/theme/dark_theme.dart';
import 'package:gphil/theme/light_theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // initially light
  ThemeData _themeData = lightMode;

  //get theme
  ThemeData get themeData => _themeData;

  //is dark Mode
  bool get isDarkMode => _themeData == darkMode;

  //set theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  //toglle theme
  void toggleTheme() {
    _themeData == darkMode ? themeData = lightMode : themeData = darkMode;
  }
}
