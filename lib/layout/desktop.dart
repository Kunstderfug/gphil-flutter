import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_links.dart';
import 'package:gphil/layout/drawer.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:provider/provider.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationProvider navigation =
        Provider.of<NavigationProvider>(context);
    final ScoreProvider score = Provider.of<ScoreProvider>(context);
    bool isScoreScreen = navigation.currentIndex == 3;

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: !isScoreScreen
            ? AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                title: Text(
                    navigation.navigationScreens[navigation.currentIndex]
                        ['title'] as String,
                    style: Theme.of(context).textTheme.titleLarge),
                toolbarHeight: 64,
              )
            : AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                title: Padding(
                  padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(score.currentScore!.composer.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 2,
                            wordSpacing: 4,
                          )),
                      const ScoreLinks(),
                      Text(score.currentScore!.shortTitle.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 2,
                            wordSpacing: 4,
                          )),
                    ],
                  ),
                ),
                toolbarHeight: 64,
              ),
        body: Row(
          children: [
            const MyDrawer(),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: navigation.navigationScreens[navigation.currentIndex]
                  ['screen'] as Widget,
            )),
          ],
        ));
  }
}
