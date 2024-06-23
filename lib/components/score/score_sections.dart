// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_section.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ScoreSections extends StatelessWidget {
  final List<Section> sections;
  const ScoreSections({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoreProvider>(builder: (context, provider, child) {
      return Wrap(
        runSpacing: isTablet(context) ? 8 : 14,
        children: [
          for (final section in sections)
            ScoreSection(
              name: section.name,
              isAutoContinue: section.autoContinueMarker != null ? true : false,
              onTap: () => provider.setCurrentSection(section.key),
              isSelected: provider.sectionKey == section.key,
            )
        ],
      );
    });
  }
}
