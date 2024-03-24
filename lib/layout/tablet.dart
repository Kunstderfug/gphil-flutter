import 'package:flutter/material.dart';
import 'package:gphil/components/constants.dart';
import 'package:gphil/components/drawer.dart';
import 'package:gphil/components/home_playlist.dart';

class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: appBar,
        drawer: const MyDrawer(),
        body: const HomePlaylist());
  }
}
