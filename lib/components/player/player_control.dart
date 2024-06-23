import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gphil/components/player/metronome.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
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
    return Consumer<PlaylistProvider>(builder: (context, p, child) {
      final s = Provider.of<ScoreProvider>(context);

      void syncProviders() {
        // final movementIndex = provider.currentSection!.movementIndex;
        final movementKey = p.currentSection!.movementKey;
        final sectionKey = p.currentSection!.key;
        s.setCurrentSectionByKey(movementKey, sectionKey);
        p.setCurrentSectionByKey(sectionKey);
      }

      return Shortcuts(
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.arrowLeft): PreviousIntent(),
          SingleActivator(LogicalKeyboardKey.arrowRight): NextIntent(),
          SingleActivator(LogicalKeyboardKey.enter): StartIntent(),
          SingleActivator(LogicalKeyboardKey.space): StopIntent(),
          SingleActivator(LogicalKeyboardKey.pageDown): StartIntent(),
          SingleActivator(LogicalKeyboardKey.pageUp): StopIntent(),
        },
        child: Actions(
          actions: {
            PreviousIntent: CallbackAction<PreviousIntent>(onInvoke: (intent) {
              p.skipToPreviousSection();
              syncProviders();
              return null;
            }),
            StartIntent: CallbackAction<StartIntent>(onInvoke: (intent) async {
              if (!p.isPlaying) {
                p.play();
              } else {
                if (!p.doublePressGuard) {
                  p.playNextSection();
                  syncProviders();
                }
              }
              return null;
            }),
            StopIntent: CallbackAction<StopIntent>(onInvoke: (intent) {
              p.stop();
              return null;
            }),
            NextIntent: CallbackAction<NextIntent>(onInvoke: (intent) {
              p.skipToNextSection();
              syncProviders();
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
                    child: IconButton(
                        iconSize: iconSizeXl,
                        onPressed: () => p.currentSectionIndex =
                            (p.currentSectionIndex - 1) % p.playlist.length,
                        icon: const Icon(Icons.skip_previous)),
                  ),

                  //play button
                  Expanded(
                    flex: 2,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                            padding: const EdgeInsets.all(0),
                            tooltip: 'Play/Pause',
                            onPressed: p.pauseOrResume,
                            icon: const RepaintBoundary(
                              child: Metronome(),
                            )),
                      ],
                    ),
                  ),

                  //next button
                  Expanded(
                    child: IconButton(
                        iconSize: iconSizeXl,
                        onPressed: () => p.currentSectionIndex =
                            (p.currentSectionIndex + 1) % p.playlist.length,
                        icon: const Icon(Icons.skip_next)),
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
