import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class PlayerHeader extends StatelessWidget {
  const PlayerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, provider, child) {
      final String songName =
          provider.playlist[provider.currentSongIndex].songName;
      final String artistName =
          provider.playlist[provider.currentSongIndex].artistName;

      return SafeArea(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          //back button
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),

          //song name
          Text(
            '$songName - $artistName',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          //menu button
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
        ]),
      );
    });
  }
}
