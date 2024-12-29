import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gphil/layout/desktop.dart';
import 'package:gphil/layout/responsive.dart';
import 'package:gphil/layout/tablet.dart';
// import 'package:gphil/providers/audio_provider.dart';
import 'package:gphil/providers/liading_state_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/screens/help_screen.dart';
import 'package:gphil/screens/performance_screen.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/screens/score_screen.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/app_update_service.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

// import 'package:gphil/src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isDark = true;

  // Only run on desktop platforms
  if (!kIsWeb) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await windowManager.ensureInitialized();

      WindowOptions windowOptions = WindowOptions(
        size: Size(1440, 900),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        minimumSize: Size(800, 600),
        maximumSize: Size(2440, 1600),
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider(isDark)),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ChangeNotifierProvider(create: (_) => AppConnection()),
      ChangeNotifierProvider(create: (_) => AppUpdateService()),
      ChangeNotifierProvider(create: (_) => LibraryProvider()),
      ChangeNotifierProvider(create: (_) => ScoreProvider()),
      ChangeNotifierProvider(create: (_) => PlaylistProvider()),
      ChangeNotifierProxyProvider<PlaylistProvider, LoadingStateProvider>(
        create: (context) =>
            LoadingStateProvider(context.read<PlaylistProvider>()),
        update: (context, playlistProvider, previous) =>
            previous ?? LoadingStateProvider(playlistProvider),
      ),
    ], child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    final n = Provider.of<NavigationProvider>(context);

    // Define shortcuts map
    final Map<ShortcutActivator, Intent> shortcuts = {
      LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.digit1,
      ): const NavigateIntent(0),
      LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.digit2,
      ): const NavigateIntent(1),
      LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.digit3,
      ): const NavigateIntent(3),
      // Add macOS command key alternatives
      LogicalKeySet(
        LogicalKeyboardKey.meta,
        LogicalKeyboardKey.digit1,
      ): const NavigateIntent(0),
      LogicalKeySet(
        LogicalKeyboardKey.meta,
        LogicalKeyboardKey.digit2,
      ): const NavigateIntent(1),
      LogicalKeySet(
        LogicalKeyboardKey.meta,
        LogicalKeyboardKey.digit3,
      ): const NavigateIntent(3),
    };

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: {
          NavigateIntent: CallbackAction<NavigateIntent>(
            onInvoke: (NavigateIntent intent) {
              n.setNavigationIndex(intent.index);
              return null;
            },
          ),
        },
        child: MaterialApp(
          title: 'GPhil Project',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
            Locale('gb'), // British English
          ],
          home: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 600,
              maxWidth: 2400,
              minHeight: 600,
              maxHeight: 800,
            ),
            child: const ResponsiveLayout(
                tabletLayout: TabletLayout(), desktopLayout: DesktopLayout()),
          ),
          routes: {
            '/performance': (context) => const PerformanceScreen(),
            '/score': (context) => const ScoreScreen(),
            '/help': (context) => const HelpScreen(),
          },
          theme: t.themeData,
          themeMode: ThemeMode.dark,
        ),
      ),
    );
  }
}

// Define Intent class
class NavigateIntent extends Intent {
  final int index;
  const NavigateIntent(this.index);
}
