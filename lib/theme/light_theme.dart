import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade200,
    primary: const Color.fromARGB(255, 218, 218, 218),
    secondary: const Color.fromARGB(255, 184, 184, 184),
    inversePrimary: Colors.grey.shade900,
    tertiary: Colors.greenAccent[700],
  ),
  listTileTheme: ListTileThemeData(
    iconColor: Colors.grey.shade800,
    selectedTileColor: Colors.purple.shade100,
    selectedColor: Colors.grey.shade800,
  ),
  hoverColor: const Color.fromRGBO(250, 222, 255, 1),
  highlightColor: const Color.fromARGB(255, 228, 184, 255),
);
