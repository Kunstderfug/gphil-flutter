// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_section.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ScoreSections extends StatelessWidget {
  final List<Section> sections;
  const ScoreSections({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoreProvider>(builder: (context, s, child) {
      void syncSections(String sectionKey) {
        final p = context.read<PlaylistProvider>();
        s.setCurrentSection(sectionKey);
        if (p.playlist.isNotEmpty &&
            p.playlist.indexWhere((el) => el.key == sectionKey) == -1 &&
            s.currentScore?.id == p.sessionScore?.id) {
          p.setCurrentSectionByKey(sectionKey);
        }
      }

      return Wrap(
        runSpacing: isTablet(context) ? 8 : 14,
        children: [
          for (Section section in sections)
            ScoreSection(
              section: section,
              onTap: () => syncSections(section.key),
              isSelected: s.sectionKey == section.key,
            )
        ],
      );
    });
  }
}
