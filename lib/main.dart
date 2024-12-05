import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gphil/layout/desktop.dart';
import 'package:gphil/layout/responsive.dart';
import 'package:gphil/layout/tablet.dart';
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

// import 'package:gphil/src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final prefs = await SharedPreferences.getInstance();
  final bool isDark = true;

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
          home: const ResponsiveLayout(
              tabletLayout: TabletLayout(), desktopLayout: DesktopLayout()),
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
