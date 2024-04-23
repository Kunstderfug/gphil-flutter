import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    background: Colors.grey.shade900,
    primary: const Color.fromARGB(255, 44, 44, 44),
    secondary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade300,
    tertiary: Colors.greenAccent[400],
  ),
  listTileTheme: ListTileThemeData(
    iconColor: Colors.grey.shade300,
    selectedTileColor: Colors.purple.shade800,
    selectedColor: Colors.grey.shade200,
  ),
  hoverColor: Colors.purple.shade900,
  highlightColor: Colors.purple.shade800,
  fontFamily: 'Roboto',
);
