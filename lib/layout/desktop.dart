import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_links.dart';
import 'package:gphil/layout/drawer.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isPerformanceScreen = navigation.currentIndex == 1;
    bool isScoreScreen = navigation.currentIndex == 2;

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: !isScoreScreen
            ? AppBar(
                flexibleSpace: backDropFilter(context),
                title: Text(
                    navigation.navigationScreens[navigation.currentIndex]
                        ['title'] as String,
                    style: Theme.of(context).textTheme.titleLarge),
                toolbarHeight: appBarSizeDesktop,
              )
            : AppBar(
                flexibleSpace: backDropFilter(context),
                title: Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 28.0),
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
                                fontSize: 24,
                                letterSpacing: 2,
                                wordSpacing: 4,
                              )),
                          Text(
                              '${currentSignalScore.value?.shortTitle.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 24,
                                letterSpacing: 2,
                                wordSpacing: 4,
                              )),
                        ],
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScoreLinks(),
                        ],
                      ),
                    ],
                  ),
                ),
                toolbarHeight: appBarSizeDesktop,
              ),
        body: Stack(children: [
          themeProvider.isDarkMode
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
                    ? MediaQuery.sizeOf(context).width - 300
                    : MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48.0),
                  child: navigation.navigationScreens[navigation.currentIndex]
                      ['screen'] as Widget,
                ),
              ),
            ],
          ),
        ]));
  }
}
