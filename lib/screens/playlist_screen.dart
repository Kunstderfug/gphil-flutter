import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/player/playlist_tile.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/models/section.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  int gridCount(double pixels) {
    return (pixels / 700).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, p, child) {
      //get the playlist

      if (p.isLoading) {
        return LoadingFiles(
            filesLoaded: p.filesLoaded, filesLength: p.playlist.length);
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount(MediaQuery.sizeOf(context).width),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3 / 1,
          ),
          itemCount: p.playlist.length,
          itemBuilder: (context, index) {
            final Section section = p.playlist[index];
            return PlaylistTile(section: section, sectionIndex: index);
          },
        ),
      );
    });
  }
}
