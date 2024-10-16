import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gphil/components/player/metronome.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
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

class Loop extends Intent {
  const Loop();
}

class PerfMode extends Intent {
  const PerfMode();
}

class Skip extends Intent {
  const Skip();
}

class Exit extends Intent {
  const Exit();
}

class AutoContinue extends Intent {
  const AutoContinue();
}

class PlayerControl extends StatelessWidget {
  const PlayerControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, p, child) {
      final n = Provider.of<NavigationProvider>(context);

      double iconSize = iconSizeMd;

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
          const SingleActivator(LogicalKeyboardKey.keyL): const Loop(),
          const SingleActivator(LogicalKeyboardKey.keyP): const PerfMode(),
          const SingleActivator(LogicalKeyboardKey.keyM): const Skip(),
          const SingleActivator(LogicalKeyboardKey.escape): const Exit(),
          const SingleActivator(LogicalKeyboardKey.keyA): const AutoContinue(),
        },
        child: Actions(
          actions: {
            HandlePreviousSection:
                CallbackAction<HandlePreviousSection>(onInvoke: (intent) {
              if (p.appState != AppState.loading) {
                p.skipToPreviousSection();
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
                  // syncProviders();
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
              }
              return null;
            }),
            Loop: CallbackAction<Loop>(onInvoke: (intent) {
              p.toggleSectionLooped();
              return null;
            }),
            Skip: CallbackAction<Skip>(onInvoke: (intent) {
              p.toggleSectionSkipped(p.currentSectionKey!);
              return null;
            }),
            Exit: CallbackAction<Exit>(onInvoke: (intent) {
              n.setScoreScreen();
              return null;
            }),
            PerfMode: CallbackAction<PerfMode>(onInvoke: (intent) {
              p.setPerformanceMode = !p.performanceMode;
              return null;
            }),
            AutoContinue: CallbackAction<AutoContinue>(onInvoke: (intent) {
              p.currentSection?.autoContinue != null
                  ? p.setCurrentSectionAutoContinue()
                  : null;
              return null;
            }),
          },
          child: Focus(
            autofocus: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: paddingXl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //previous button
                  Expanded(
                    child: IconButton(
                        iconSize: iconSize,
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
                        iconSize: iconSize,
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
