import 'package:flutter/material.dart';
import 'package:gphil/components/dark_mode.dart';
import 'package:gphil/layout/navigation_item.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      //logo
      DrawerHeader(
          child: Center(
        child: Icon(
          Icons.music_note,
          size: 40,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      )),

      //Home
      const NavigationItem(
          title: 'L I B R A R Y', icon: Icons.library_books_rounded, index: 0),

      //Playlist
      const NavigationItem(
          title: 'P L A Y L I S T', icon: Icons.playlist_play, index: 1),

//song
      const NavigationItem(
          title: 'P E R F O R M A N C E', icon: Icons.piano, index: 2),

      //DARK MODE
      const Padding(
        padding: EdgeInsets.all(25.0),
        child: DarkModeSlider(),
      ),
    ]);
  }
}
