import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';

ThemeData darkMode = ThemeData(
    colorScheme: ColorScheme.dark(
      surface: Colors.grey.shade900,
      primary: const Color.fromARGB(255, 44, 44, 44),
      secondary: Colors.grey.shade800,
      inversePrimary: Colors.grey.shade300,
      tertiary: Colors.purple.shade900,
      scrim: Colors.purple.shade700,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: Colors.grey.shade300,
      // selectedTileColor: Colors.purple.shade800,
      selectedColor: Colors.grey.shade200,
    ),
    hoverColor: highlightColor.withValues(alpha: 0.2),
    highlightColor: highlightColor,
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.grey.shade400),
      titleSmall: TextStyle(color: Colors.grey.shade400),
      titleMedium: TextStyle(color: Colors.grey.shade400),
    ));
