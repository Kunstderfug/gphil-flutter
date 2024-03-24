import 'dart:developer';

import 'package:gphil/layout/desktop.dart';
import 'package:gphil/layout/responsive.dart';
import 'package:gphil/layout/tablet.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool('isDarkMode') ?? false;
  log(prefs.getBool('isDarkMode').toString());
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider(isDark)),
      ChangeNotifierProvider(create: (_) => PlaylistProvider()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ResponsiveLayout(
          tabletLayout: TabletLayout(), desktopLayout: DesktopLayout()),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
