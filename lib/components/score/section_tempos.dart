import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/session_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SectionTempos extends StatelessWidget {
  final List<int> tempos;
  const SectionTempos({super.key, required this.tempos});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final scoreProvider = Provider.of<ScoreProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    bool isSelected(int tempo) {
      if (scoreProvider.userTempo != null) {
        return scoreProvider.userTempo == tempo;
      } else {
        return scoreProvider.currentTempo == tempo;
      }
    }

    bool isDefaultTempo(int tempo) =>
        scoreProvider.currentSection.defaultTempo == tempo;

    return Column(
      children: [
        const Text('Section tempos:'),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 16,
          children: [
            for (int tempo in tempos)
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
                onPressed: () {
                  scoreProvider.setCurrentTempo(tempo);
                  //if sessionPlaylist contains current section, use it
                  if (scoreProvider.userTempo != null &&
                      sessionProvider
                          .containsMovement(scoreProvider.currentMovement)) {
                    log(sessionProvider.sessionMovements.length.toString());
                    sessionProvider
                        .removeMovement(scoreProvider.currentMovement);
                    sessionProvider.addMovement(scoreProvider.currentScore!,
                        scoreProvider.currentMovement);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    tempo.toString(),
                  ),
                ),
              )
          ],
        ),
      ],
    );
  }
}
