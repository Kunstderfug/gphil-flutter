import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_section.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionsArea extends StatelessWidget {
  const SectionsArea({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<ScoreProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);

    setSection(Section section) {
      if (!p.isPlaying) {
        s.setCurrentSectionByKey(section.movementKey, section.key);
        p.setCurrentSectionByKey(section.key);
      }
    }

    return Wrap(runSpacing: paddingMd, spacing: 0, children: [
      for (final section in p.currentMovementSections)
        ScoreSection(
            name: section.name,
            isAutoContinue: section.autoContinueMarker != null ? true : false,
            onTap: () => setSection(section),
            isSelected: p.currentSectionKey == section.key),
    ]);
  }
}