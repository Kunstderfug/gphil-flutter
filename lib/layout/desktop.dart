import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_links.dart';
import 'package:gphil/layout/drawer.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final l = Provider.of<LibraryProvider>(context);
    final t = Provider.of<ThemeProvider>(context);
    final s = Provider.of<ScoreProvider>(context);

    bool isPerformanceScreen = n.currentIndex == 1;
    bool isScoreScreen = n.currentIndex == 2;
    bool isLibraryScreen = n.currentIndex == 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: !isScoreScreen
          ? AppBar(
              title: Text(
                  n.navigationScreens[n.currentIndex]['title'] as String,
                  style: Theme.of(context).textTheme.titleMedium),
              toolbarHeight: appBarSizeDesktop,
            )
          : AppBar(
              title: Padding(
                padding:
                    const EdgeInsets.only(left: paddingMd, right: paddingMd),
                child: Stack(
                  fit: StackFit.passthrough,
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            '${currentSignalScore.value?.composer.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: fontSizeMd,
                              letterSpacing: 2,
                              wordSpacing: 4,
                            )),
                        Text(
                            '${currentSignalScore.value?.shortTitle.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: fontSizeMd,
                              letterSpacing: 2,
                              wordSpacing: 4,
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScoreLinks(
                            pianoScoreUrl: s.currentScore?.pianoScoreUrl,
                            fullScoreUrl: s.currentScore?.fullScoreUrl),
                      ],
                    ),
                  ],
                ),
              ),
              toolbarHeight: appBarSizeDesktop,
            ),
      body: Stack(children: [
        t.isDarkMode
            ? Image.asset('assets/images/bg-dark-desktop.png',
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                fit: BoxFit.fill)
            : Image.asset('assets/images/bg-light-desktop1.png',
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                fit: BoxFit.fill),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            !isPerformanceScreen ? const MyDrawer() : const SizedBox(),
            SizedBox(
              width: !isPerformanceScreen
                  ? MediaQuery.sizeOf(context).width - 240
                  : MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(paddingXl),
                child: n.navigationScreens[n.currentIndex]['screen'] as Widget,
              ),
            ),
          ],
        ),
      ]),
      floatingActionButton: isLibraryScreen
          ? FloatingActionButton(
              backgroundColor: highlightColor.withOpacity(0.7),
              onPressed: l.getLibrary,
              tooltip: 'Refresh Library',
              child: !l.isLoading
                  ? const Icon(Icons.refresh,
                      size: 32,
                      color: Colors.white,
                      semanticLabel: 'Refresh library')
                  : const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
            )
          : null,
    );
  }
}
