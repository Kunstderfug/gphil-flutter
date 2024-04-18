import 'package:gphil/layout/desktop.dart';
import 'package:gphil/layout/responsive.dart';
import 'package:gphil/layout/tablet.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/screens/home_screen.dart';
import 'package:gphil/screens/library_screen.dart';
import 'package:gphil/screens/song_screen.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool('isDarkMode') ?? false;
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider(isDark)),
      ChangeNotifierProvider(create: (_) => PlaylistProvider()),
      ChangeNotifierProvider(create: (_) => LibraryProvider()),
      ChangeNotifierProvider(create: (_) => ScoreProvider()),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      // ChangeNotifierProvider(create: (_) => PersistentDataProvider()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ResponsiveLayout(
          tabletLayout: TabletLayout(), desktopLayout: DesktopLayout()),
      routes: {
        '/song': (context) => const SongScreen(),
        '/library': (context) => const LibraryScreen(),
        '/playlist': (context) => const HomeScreen(),
      },
      theme: provider.themeData,
      themeAnimationStyle: AnimationStyle(
        duration: const Duration(milliseconds: 200),
        curve: Curves.decelerate,
        reverseCurve: Curves.easeInOutCubic,
        reverseDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}
