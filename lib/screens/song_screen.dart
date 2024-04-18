import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/player/player_control.dart';
import 'package:gphil/components/player/player_header.dart';
import 'package:gphil/components/player/player_image.dart';
import 'package:gphil/components/player/playlist_control.dart';
import 'package:gphil/components/player/progress_bar.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:provider/provider.dart';
// import 'package:gphil/models/song.dart';

class SongScreen extends StatelessWidget {
  const SongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaylistProvider>(context);
    if (provider.sessionPlayers.isEmpty &&
        provider.filesLoaded < provider.playlist.length) {
      return const FileLoading();
    } else {
      return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // custom app bar
                PlayerHeader(),

                SizedBox(
                  height: 25,
                ),
                // album artwork
                PlayerImage(),

                SizedBox(
                  height: 25,
                ),

                RepaintBoundary(child: PlaylistControl()),
                RepaintBoundary(child: ProgressBar()),

                SizedBox(
                  height: 18,
                ),

                PlayerControl(),
              ],
            ),
          ));
    }
  }
}
