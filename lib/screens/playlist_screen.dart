import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/playlist_tile.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/models/song.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  int gridCount(double pixels) {
    return (pixels / 700).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, provider, child) {
      //get the playlist

      if (provider.isLoading) {
        return const FileLoading();
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount(MediaQuery.of(context).size.width),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3 / 1,
          ),
          itemCount: provider.playlist.length,
          itemBuilder: (context, index) {
            final Song song = provider.playlist[index];
            return PlaylistTile(song: song, songIndex: index);
          },
        ),
      );
    });
  }
}

// set up grid view

