import 'package:flutter/material.dart';
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
    final navigation = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isScoreScreen = navigation.currentIndex == 2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: isScoreScreen
          ? AppBar(
              flexibleSpace: backDropFilter(context),
              elevation: 0,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withOpacity(0.9),
              title: Text(
                  '${currentSignalScore.value?.composer.toUpperCase()} - ${currentSignalScore.value?.shortTitle.toUpperCase()}',
                  style: TextStyle(
                    fontSize: TextStyles().textLg.fontSize,
                    letterSpacing: 4,
                  ),
                  overflow: TextOverflow.ellipsis),
            )
          : AppBar(
              flexibleSpace: backDropFilter(context),
              elevation: 0,
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withOpacity(0.9),
              title: Text(
                  navigation.navigationScreens[navigation.currentIndex]['title']
                      as String,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          themeProvider.isDarkMode
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
              child: navigation.navigationScreens[navigation.currentIndex]
                  ['screen'] as Widget,
            ),
          ),
        ],
      ),
    );
  }
}
