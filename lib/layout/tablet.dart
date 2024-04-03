import 'package:flutter/material.dart';
import 'package:gphil/components/constants.dart';
import 'package:gphil/layout/drawer.dart';
// import 'package:gphil/components/home_playlist.dart';
import 'package:gphil/screens/library_screen.dart';

class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: appBar,
        bottomNavigationBar: const BottomBar(),
        drawer: const MyDrawer(),
        body: const LibraryScreen());
  }
}
