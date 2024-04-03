import 'package:flutter/material.dart';
import 'package:gphil/components/constants.dart';
import 'package:gphil/layout/drawer.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/screens/home_screen.dart';
import 'package:gphil/screens/library_screen.dart';
import 'package:gphil/screens/score_screen.dart';
import 'package:gphil/screens/song_screen.dart';
// import 'package:gphil/screens/song_screen.dart';
import 'package:provider/provider.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  final List<Widget> screens = const [
    LibraryScreen(),
    HomeScreen(),
    SongScreen(),
    ScoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navigation = Provider.of<NavigationProvider>(context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: appBar,
        body: Row(
          children: [
            const MyDrawer(),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: screens[navigation.currentIndex],
            )),
          ],
        ));
  }
}
