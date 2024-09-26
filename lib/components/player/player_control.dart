import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gphil/components/player/metronome.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class HandlePreviousSection extends Intent {
  const HandlePreviousSection();
}

class HandleNextSection extends Intent {
  const HandleNextSection();
}

class StartOrContinue extends Intent {
  const StartOrContinue();
}

class Stop extends Intent {
  const Stop();
}

class PlayerControl extends StatelessWidget {
  const PlayerControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, p, child) {
      final s = Provider.of<ScoreProvider>(context);

      void syncProviders() {
        final movementKey = p.currentSection!.movementKey;
        final sectionKey = p.currentSection!.key;
        s.setCurrentSectionByKey(movementKey, sectionKey);
        p.setCurrentSectionByKey(sectionKey);
      }

      return Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.arrowLeft):
              const HandlePreviousSection(),
          const SingleActivator(LogicalKeyboardKey.arrowRight):
              const HandleNextSection(),
          const SingleActivator(LogicalKeyboardKey.enter):
              const StartOrContinue(),
          const SingleActivator(LogicalKeyboardKey.space): const Stop(),
          const SingleActivator(LogicalKeyboardKey.pageDown):
              const StartOrContinue(),
          const SingleActivator(LogicalKeyboardKey.pageUp):
              !p.onePedalMode ? const Stop() : const StartOrContinue(),
        },
        child: Actions(
          actions: {
            HandlePreviousSection:
                CallbackAction<HandlePreviousSection>(onInvoke: (intent) {
              if (p.appState != AppState.loading) {
                p.skipToPreviousSection();
                syncProviders();
              }
              return null;
            }),
            StartOrContinue:
                CallbackAction<StartOrContinue>(onInvoke: (intent) async {
              if (!p.isPlaying && p.appState != AppState.loading) {
                p.play();
              } else {
                if (!p.doublePressGuard) {
                  p.playNextSection();
                  syncProviders();
                }
              }

              return null;
            }),
            Stop: CallbackAction<Stop>(onInvoke: (intent) {
              p.stop();
              return null;
            }),
            HandleNextSection:
                CallbackAction<HandleNextSection>(onInvoke: (intent) {
              if (p.appState != AppState.loading) {
                p.skipToNextSection();
                syncProviders();
              }
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
                        onPressed: () => !p.layerFilesDownloading
                            ? p.currentSectionIndex =
                                (p.currentSectionIndex - 1) % p.playlist.length
                            : null,
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
                            onPressed: !p.layerFilesDownloading
                                ? p.pauseOrResume
                                : null,
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
                        onPressed: () => !p.layerFilesDownloading
                            ? p.currentSectionIndex =
                                (p.currentSectionIndex + 1) % p.playlist.length
                            : null,
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
