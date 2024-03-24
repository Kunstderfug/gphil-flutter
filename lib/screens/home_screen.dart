import 'package:gphil/components/constants.dart';
import 'package:gphil/components/drawer.dart';
import 'package:gphil/components/home_playlist.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: appBar,
      drawer: const MyDrawer(),
      body: const HomePlaylist(),
    );
  }
}
