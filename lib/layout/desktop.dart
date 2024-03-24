import 'package:flutter/material.dart';
import 'package:gphil/components/constants.dart';
import 'package:gphil/components/drawer.dart';
import 'package:gphil/components/home_playlist.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: appBar,
        body: const Row(
          children: [
            MyDrawer(),
            Expanded(child: HomePlaylist()),
          ],
        ));
  }
}
