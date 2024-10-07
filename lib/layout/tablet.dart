import 'package:flutter/material.dart';
import 'package:gphil/components/performance/sidebar.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/layout/drawer.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final t = Provider.of<ThemeProvider>(context);
    final s = Provider.of<ScoreProvider>(context);

    bool isScoreScreen = n.currentIndex == 2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isScoreScreen
          ? AppBar(
              elevation: 0,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withOpacity(0.9),
              title: Text(
                  '${s.currentScore?.composer.toUpperCase()} - ${s.currentScore?.shortTitle.toUpperCase()}',
                  style: TextStyle(
                    fontSize: TextStyles().textLg.fontSize,
                    letterSpacing: 4,
                  ),
                  overflow: TextOverflow.ellipsis),
            )
          : AppBar(
              elevation: 0,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withOpacity(0.9),
              title: Text(
                  n.navigationScreens[n.currentIndex]['title'] as String,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
      drawer: const MyDrawer(child: PerformanceSidebar()),
      body: Stack(
        children: [
          t.isDarkMode
              ? Image.asset(
                  'assets/images/bg-dark1.png',
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  fit: BoxFit.fill,
                )
              : Image.asset('assets/images/bg-light.png',
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  fit: BoxFit.fill),
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: n.navigationScreens[n.currentIndex]['screen'] as Widget,
            ),
          ),
        ],
      ),
    );
  }
}
