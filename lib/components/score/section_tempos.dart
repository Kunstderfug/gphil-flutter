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
      //TODO need work for syncing section between providers
      if (p.currentMovementKey != null && p.currentSectionKey != null) {
        p.tempoForAllSectionsEnabled
            ? p.setTempoForAllSections(tempo)
            : p.setUserTempo(tempo, p.currentSection!);
      }
    }

    bool tempoExists(int tempo) {
      if (!p.layersEnabled) return true;
      if (section.tempoRangeLayers == null) return true;
      return section.tempoRangeLayers?.contains(tempo) ?? false;
    }

    double setOpacity(int tempo) {
      if (!p.layersEnabled) return 1.0;
      if (p.layersEnabled &&
          section.tempoRangeLayers != null &&
          !section.tempoRangeLayers!.contains(tempo)) return 0.5;
      return 1.0;
    }

    return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: paddingMd),
            child: Text('Tempos: ', style: TextStyle(fontSize: fontSizeMd)),
          ),
          for (int tempo in section.tempoRange)
            Opacity(
              opacity: setOpacity(tempo),
              child: TextButton(
                style: TextButton.styleFrom(
                  elevation: 0,
                  animationDuration: const Duration(milliseconds: 200),
                  backgroundColor: isSelected(tempo)
                      ? t.themeData.highlightColor
                      : t.themeData.colorScheme.primary,
                  foregroundColor: t.themeData.colorScheme.inversePrimary,
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
                  padding: const EdgeInsets.all(paddingMd),
                  child: Text(
                    tempo.toString(),
                    style: TextStyle(
                      fontSize: fontSizeSm,
                      fontWeight: isSelected(tempo) ? FontWeight.bold : null,
                    ),
                  ),
                ),
              ),
            ),
        ]);
  }
}
