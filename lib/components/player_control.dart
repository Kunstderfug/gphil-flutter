import 'package:flutter/material.dart';
import 'package:gphil/components/neo.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class PlayerControl extends StatelessWidget {
  const PlayerControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //previous button
            Expanded(
              child: Neo(
                child: IconButton(
                    onPressed: provider.playPreviousSong,
                    icon: const Icon(Icons.skip_previous)),
              ),
            ),
            const SizedBox(
              width: 18,
            ),
            //play button
            Expanded(
              flex: 2,
              child: Neo(
                child: IconButton(
                    onPressed: provider.pauseOrResume,
                    icon: Icon(
                        provider.isPlaying ? Icons.pause : Icons.play_arrow)),
              ),
            ),
            const SizedBox(
              width: 18,
            ),
            //next button
            Expanded(
              child: Neo(
                child: IconButton(
                    onPressed: provider.playNextSong,
                    icon: const Icon(Icons.skip_next)),
              ),
            ),
          ],
        ),
      );
    });
  }
}
