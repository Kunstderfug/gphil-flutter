import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:gphil/layout/desktop.dart';
import 'package:gphil/layout/responsive.dart';
import 'package:gphil/layout/tablet.dart';

import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/screens/home_screen.dart';
import 'package:gphil/screens/library_screen.dart';
import 'package:gphil/screens/performance_screen.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/app_update_service.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:gphil/src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool('isDarkMode') ?? true;
  // await RustLib.init();
  //
  // Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    // Forward logs to the console.
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
      zone: record.zone,
      error: record.error,
      stackTrace: record.stackTrace,
    );
    // TODO: if needed, forward to Sentry.io, Crashlytics, etc.
  });

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider(isDark)),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ChangeNotifierProvider(create: (_) => AppConnection()),
      ChangeNotifierProvider(create: (_) => AppUpdateService()),
      ChangeNotifierProvider(create: (_) => LibraryProvider()),
      ChangeNotifierProvider(create: (_) => ScoreProvider()),
      ChangeNotifierProvider(create: (_) => PlaylistProvider()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'GPhil Project',
      debugShowCheckedModeBanner: false,
      home: const ResponsiveLayout(
          tabletLayout: TabletLayout(), desktopLayout: DesktopLayout()),
      routes: {
        '/performance': (context) => const PerformanceScreen(),
        '/library': (context) => const LibraryScreen(),
        '/playlist': (context) => const HomeScreen(),
      },
      theme: t.themeData,
      themeMode: ThemeMode.dark,
    );
  }
}
