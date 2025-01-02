import 'package:flutter/material.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionTempos extends StatelessWidget {
  final Section section;
  const SectionTempos({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context);
    final s = Provider.of<ScoreProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);
    final ac = Provider.of<AppConnection>(context);
    final pc = PersistentDataController();

    bool isSelected(int tempo) {
      return p.playlist.isNotEmpty && p.currentSectionKey == section.key
          ? p.currentTempo == tempo
          : s.currentTempo == tempo;
    }

    bool isDefaultTempo(int tempo) => section.defaultTempo == tempo;

    void setTempo(int tempo) {
      if (p.currentMovementKey != null && p.currentSectionKey != null) {
        p.tempoForAllSectionsEnabled
            ? p.setTempoForAllSections(tempo)
            : p.setUserTempo(tempo, p.currentSection!);
      }
    }

    return FutureBuilder<List<int>>(
      future: pc.getAvailableTempos(section.scoreId, section.name),
      builder: (context, snapshot) {
        final List<int> availableTempos = snapshot.data ?? [];

        bool tempoExists(int tempo) {
          if (ac.appState == AppState.online) {
            return !p.layersEnabled ||
                (section.tempoRangeLayers?.contains(tempo) ?? false);
          } else {
            // Offline mode - check if tempo is available locally
            return availableTempos.contains(tempo);
          }
        }

        double setOpacity(int tempo) {
          if (ac.appState == AppState.online) {
            if (!p.layersEnabled) return 1.0;
            if (p.layersEnabled &&
                section.tempoRangeLayers != null &&
                !section.tempoRangeLayers!.contains(tempo)) {
              return globalDisabledOpacity;
            }
            return 1.0;
          } else {
            // Offline mode - set opacity based on local file availability
            return availableTempos.contains(tempo)
                ? 1.0
                : globalDisabledOpacity;
          }
        }

        return Column(
          children: [
            Text('T E M P O S: ', style: TextStyle(fontSize: fontSizeLg)),
            const SizedBox(height: paddingMd),
            Wrap(
              spacing: section.tempoRange.length > 6 ? -10 : 0,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                for (int tempo in section.tempoRange)
                  Opacity(
                    opacity: setOpacity(tempo),
                    child: MouseRegion(
                      cursor: tempoExists(tempo)
                          ? SystemMouseCursors.click
                          : SystemMouseCursors.forbidden,
                      child: AbsorbPointer(
                        absorbing: !tempoExists(tempo) ||
                            p.appState == AppState.loading,
                        child: Tooltip(
                          message: tempoExists(tempo)
                              ? 'Set tempo to $tempo'
                              : ac.appState == AppState.online
                                  ? 'Tempo $tempo is not available for layers mode'
                                  : 'Tempo $tempo is not available offline',
                          waitDuration: const Duration(milliseconds: 500),
                          showDuration: const Duration(seconds: 2),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              elevation: 0,
                              animationDuration:
                                  const Duration(milliseconds: 200),
                              backgroundColor: isSelected(tempo)
                                  ? t.themeData.highlightColor
                                  : t.themeData.colorScheme.primary,
                              foregroundColor:
                                  t.themeData.colorScheme.inversePrimary,
                              shape: CircleBorder(
                                side: BorderSide(
                                  width: 2,
                                  color: isDefaultTempo(tempo)
                                      ? t.themeData.highlightColor
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            onPressed: () => tempoExists(tempo)
                                ? p.appState != AppState.loading
                                    ? setTempo(tempo)
                                    : null
                                : null,
                            child: Padding(
                              padding: EdgeInsets.all(
                                  section.tempoRange.length > 6 ? 12 : 16),
                              child: Text(
                                tempo.toString(),
                                style: TextStyle(
                                  fontSize: fontSizeSm,
                                  fontWeight: isSelected(tempo)
                                      ? FontWeight.bold
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
