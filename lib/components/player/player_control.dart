import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gphil/components/player/metronome.dart';
import 'package:gphil/components/player/metronome_volume.dart';
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

      void startOrContinue() {
        if (!p.isPlaying && p.appState != AppState.loading && !p.isLoading) {
          p.play();
        } else {
          if (!p.doublePressGuard) {
            p.playNextSection();
          }
        }
      }

      void handlePreviousSection() {
        if (p.appState != AppState.loading && !p.isLoading) {
          p.skipToPreviousSection();
        }
      }

      void handleNextSection() {
        if (p.appState != AppState.loading && !p.isLoading) {
          p.skipToNextSection();
        }
      }

      return Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.arrowLeft):
              const HandlePreviousSection(),
          const SingleActivator(LogicalKeyboardKey.arrowRight):
              const HandleNextSection(),
          const SingleActivator(LogicalKeyboardKey.enter):
              const StartOrContinue(),
          const SingleActivator(LogicalKeyboardKey.space):
              !p.onePedalMode ? const Stop() : const StartOrContinue(),
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
              handlePreviousSection();
              return null;
            }),
            StartOrContinue:
                CallbackAction<StartOrContinue>(onInvoke: (intent) async {
              startOrContinue();
              return null;
            }),
            Stop: CallbackAction<Stop>(onInvoke: (intent) async {
              await p.stop();
              return null;
            }),
            HandleNextSection:
                CallbackAction<HandleNextSection>(onInvoke: (intent) {
              handleNextSection();
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
            Exit: CallbackAction<Exit>(onInvoke: (intent) async {
              await p.stop();
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //previous button
                      Expanded(
                        child: IconButton(
                            iconSize: iconSize,
                            tooltip: 'Previous section. shortcut: left arrow',
                            onPressed: () => !p.layerFilesDownloading
                                ? handlePreviousSection()
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
                                tooltip: 'Play/Stop, shortcut: Enter/Space',
                                onPressed: () => !p.layerFilesDownloading
                                    ? startOrContinue()
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
                            tooltip: 'Next section. shortcut: right arrow',
                            onPressed: () => !p.layerFilesDownloading
                                ? handleNextSection()
                                : null,
                            icon: const Icon(Icons.skip_next)),
                      ),
                    ],
                  ),
                  MetronomeVolume(metronomeVolume: p.metronomeVolume),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
