import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/models/section.dart';
// import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionTempos extends StatelessWidget {
  final Section section;
  const SectionTempos({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final s = Provider.of<ScoreProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);
    bool isSelected(int tempo) {
      return p.playlist.isNotEmpty && p.currentSectionKey == section.key
          ? p.currentTempo == tempo
          : s.currentTempo == tempo;
    }

    bool isDefaultTempo(int tempo) => section.defaultTempo == tempo;

    void setTempoAndPlay(int tempo) {
      p.setUserTempo(tempo);
      s.setCurrentTempo(tempo);
    }

    return Column(
      children: [
        const Text('Section tempos:'),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 0,
          runSpacing: separatorXs,
          children: [
            for (int tempo in section.tempoRange)
              TextButton(
                style: TextButton.styleFrom(
                  elevation: 0,
                  animationDuration: const Duration(milliseconds: 200),
                  backgroundColor: isSelected(tempo)
                      ? theme.themeData.highlightColor
                      : theme.themeData.colorScheme.primary,
                  foregroundColor: theme.themeData.colorScheme.inversePrimary,
                  shape: CircleBorder(
                    side: BorderSide(
                      width: 2,
                      color: isDefaultTempo(tempo)
                          ? theme.themeData.highlightColor
                          : Colors.transparent,
                    ),
                  ),
                ),
                onPressed: () => setTempoAndPlay(tempo),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    tempo.toString(),
                    style: TextStyle(
                      fontSize: fontSizeSm,
                      fontWeight: isSelected(tempo) ? FontWeight.bold : null,
                    ),
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }
}
