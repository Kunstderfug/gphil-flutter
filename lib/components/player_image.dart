import 'package:flutter/material.dart';
import 'package:gphil/components/neo.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class PlayerImage extends StatelessWidget {
  const PlayerImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Neo(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              provider.playlist[provider.currentSongIndex!].albumArtImagePath,
              isAntiAlias: true,
              filterQuality: FilterQuality.high,
              fit: BoxFit.cover,
              width: 300,
              height: 300,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
      );
    });
  }
}
