import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gphil/components/neo.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class PreviousIntent extends Intent {
  const PreviousIntent();
}

class NextIntent extends Intent {
  const NextIntent();
}

class StartIntent extends Intent {
  const StartIntent();
}

class StopIntent extends Intent {
  const StopIntent();
}

class PlayerControl extends StatelessWidget {
  const PlayerControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, provider, child) {
      return Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowLeft): PreviousIntent(),
          SingleActivator(LogicalKeyboardKey.arrowRight): NextIntent(),
          SingleActivator(LogicalKeyboardKey.enter): StartIntent(),
          SingleActivator(LogicalKeyboardKey.space): StopIntent(),
        },
        child: Actions(
          actions: {
            PreviousIntent: CallbackAction<PreviousIntent>(onInvoke: (intent) {
              provider.currentSongIndex =
                  (provider.currentSongIndex - 1) % provider.playlist.length;
              return null;
            }),
            StartIntent: CallbackAction<StartIntent>(onInvoke: (intent) {
              if (!provider.isPlaying) {
                provider.play();
              } else {
                provider.playNextSong();
              }
              return null;
            }),
            StopIntent: CallbackAction<StopIntent>(onInvoke: (intent) {
              provider.stop();
              return null;
            }),
            NextIntent: CallbackAction<NextIntent>(onInvoke: (intent) {
              provider.currentSongIndex =
                  (provider.currentSongIndex + 1) % provider.playlist.length;
              return null;
            }),
          },
          child: Focus(
            autofocus: true,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //previous button
                  Expanded(
                    child: Neo(
                      child: IconButton(
                          onPressed: () => provider.currentSongIndex =
                              (provider.currentSongIndex - 1) %
                                  provider.playlist.length,
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
                          icon: Icon(provider.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow)),
                    ),
                  ),
                  const SizedBox(
                    width: 18,
                  ),
                  //next button
                  Expanded(
                    child: Neo(
                      child: IconButton(
                          onPressed: () => provider.currentSongIndex =
                              (provider.currentSongIndex + 1) %
                                  provider.playlist.length,
                          icon: const Icon(Icons.skip_next)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
