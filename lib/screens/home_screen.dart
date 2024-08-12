import 'package:gphil/screens/playlist_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        // appBar: appBar,
        // drawer: const MyDrawer(),
        body: const PlaylistScreen());
  }
}
