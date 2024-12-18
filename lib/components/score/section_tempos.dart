import 'package:flutter/material.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/models/section.dart';
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

    bool tempoExists(int tempo) {
      return !p.layersEnabled ||
          (section.tempoRangeLayers?.contains(tempo) ?? false);
    }

    double setOpacity(int tempo) {
      if (!p.layersEnabled) return 1.0;
      if (p.layersEnabled &&
          section.tempoRangeLayers != null &&
          !section.tempoRangeLayers!.contains(tempo)) {
        return 0.3;
      }
      return 1.0;
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
                      absorbing:
                          !tempoExists(tempo) || p.appState == AppState.loading,
                      child: Tooltip(
                        message: tempoExists(tempo)
                            ? 'Set tempo to $tempo'
                            : 'Tempo $tempo is not available for layers mode',
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
                                fontWeight:
                                    isSelected(tempo) ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
      ],
    );
  }
}
