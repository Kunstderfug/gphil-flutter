import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gphil/components/library/library_search.dart';
import 'package:gphil/components/player/metronome.dart';
import 'package:gphil/components/player/metronome_volume.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PlayerControl extends StatelessWidget {
  const PlayerControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, p, child) {
      final n = Provider.of<NavigationProvider>(context);
      final l = Provider.of<LibraryProvider>(context);

      final List<ShortcutAction> actions = [
        ShortcutAction(
          intent: const HandlePreviousSection(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.arrowLeft)],
          onInvoke: () =>
              !p.layerFilesDownloading ? p.skipToPreviousSection() : null,
          tooltip: 'Previous section. shortcut: left arrow',
          icon: Icons.skip_previous,
        ),
        ShortcutAction(
          intent: const HandleNextSection(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.arrowRight)],
          onInvoke: () =>
              !p.layerFilesDownloading ? p.skipToNextSection() : null,
          tooltip: 'Next section. shortcut: right arrow',
          icon: Icons.skip_next,
        ),
        ShortcutAction(
          intent: const StartOrContinue(),
          shortcuts: const [
            SingleActivator(LogicalKeyboardKey.enter),
            SingleActivator(LogicalKeyboardKey.pageDown),
          ],
          onInvoke: () {
            if (!p.isPlaying &&
                p.appState != AppState.loading &&
                !p.isLoading) {
              p.play();
            } else if (!p.doublePressGuard) {
              p.playNextSection();
            }
          },
        ),
        ShortcutAction(
          intent: const Stop(),
          shortcuts: [
            if (!p.onePedalMode) ...[
              const SingleActivator(LogicalKeyboardKey.space),
              const SingleActivator(LogicalKeyboardKey.pageUp),
            ]
          ],
          onInvoke: () => p.stop(),
        ),
        ShortcutAction(
          intent: const Loop(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.keyL)],
          onInvoke: () => p.toggleSectionLooped(),
        ),
        ShortcutAction(
          intent: const PerfMode(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.keyP)],
          onInvoke: () => p.setPerformanceMode = !p.performanceMode,
        ),
        ShortcutAction(
          intent: const Skip(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.keyS)],
          onInvoke: () => p.currentSectionKey != null
              ? p.toggleSectionSkipped(p.currentSectionKey!)
              : null,
        ),
        ShortcutAction(
          intent: const Exit(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.escape)],
          onInvoke: () async {
            await p.stop();
            n.setScoreScreen();
          },
        ),
        ShortcutAction(
          intent: const AutoContinue(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.keyA)],
          onInvoke: () => p.currentSection?.autoContinue != null
              ? p.setCurrentSectionAutoContinue()
              : null,
        ),
        ShortcutAction(
          intent: const ToggleMetronomeIntent(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.keyM)],
          onInvoke: () => p.setMetronomeMuted(),
        ),
        ShortcutAction(
          intent: const DecreaseVolumeIntent(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.comma)],
          onInvoke: () {
            // First calculate with clamp
            final clampedVolume = (p.metronomeVolume - 0.1).clamp(0.0, 1.0);
            // Then round to one decimal place
            final roundedVolume = (clampedVolume * 10).round() / 10;
            p.setMetronomeVolume(roundedVolume);
          },
        ),
        ShortcutAction(
          intent: const IncreaseVolumeIntent(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.period)],
          onInvoke: () {
            // First calculate with clamp
            final clampedVolume = (p.metronomeVolume + 0.1).clamp(0.0, 1.0);
            // Then round to one decimal place
            final roundedVolume = (clampedVolume * 10).round() / 10;
            p.setMetronomeVolume(roundedVolume);
          },
        ),
        ShortcutAction(
          intent: const EnableMetronomeBellIntent(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.keyB)],
          onInvoke: () {
            p.setMetronomeBellEnabled();
          },
        ),
        ShortcutAction(
          intent: const OpenGlobalSearchIntent(),
          shortcuts: const [SingleActivator(LogicalKeyboardKey.keyF)],
          onInvoke: () {
            showDialog(
              context: context,
              useRootNavigator: false,
              builder: (context) => LibrarySearch(
                l: l,
                isGlobalSearch: true,
                closeParentDialog: true,
              ),
            );
          },
        ),
      ];

      // Convert actions to shortcuts map
      final shortcuts = Map.fromEntries(
        actions.expand((action) => action.shortcuts.map(
              (shortcut) => MapEntry(shortcut, action.intent),
            )),
      );

      // Convert actions to actions map
      final actionMap = Map.fromEntries(
        actions.map((action) => MapEntry(
              action.intent.runtimeType,
              CallbackAction<Intent>(onInvoke: (_) => action.onInvoke()),
            )),
      );

      return Shortcuts(
        shortcuts: shortcuts,
        child: Actions(
          actions: actionMap,
          child: Focus(
            autofocus: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: paddingXl),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Previous button
                      Expanded(
                        child: IconButton(
                          iconSize: iconSizeMd,
                          tooltip: actions[0].tooltip,
                          onPressed: actions[0].onInvoke,
                          icon: Icon(actions[0].icon),
                        ),
                      ),

                      // Play button
                      Expanded(
                        flex: 2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              padding: const EdgeInsets.all(0),
                              tooltip: 'Play/Stop, shortcut: Enter/Space',
                              onPressed: actions[2].onInvoke,
                              icon: const RepaintBoundary(
                                child: Metronome(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Next button
                      Expanded(
                        child: IconButton(
                          iconSize: iconSizeMd,
                          tooltip: actions[1].tooltip,
                          onPressed: actions[1].onInvoke,
                          icon: Icon(actions[1].icon),
                        ),
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

// Helper class to structure shortcuts and actions
class ShortcutAction {
  final Intent intent;
  final List<ShortcutActivator> shortcuts;
  final Function() onInvoke;
  final String? tooltip;
  final IconData? icon;

  const ShortcutAction({
    required this.intent,
    required this.shortcuts,
    required this.onInvoke,
    this.tooltip,
    this.icon,
  });
}

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

class ToggleMetronomeIntent extends Intent {
  const ToggleMetronomeIntent();
}

class DecreaseVolumeIntent extends Intent {
  const DecreaseVolumeIntent();
}

class IncreaseVolumeIntent extends Intent {
  const IncreaseVolumeIntent();
}

class EnableMetronomeBellIntent extends Intent {
  const EnableMetronomeBellIntent();
}

class OpenGlobalSearchIntent extends Intent {
  const OpenGlobalSearchIntent();
}
