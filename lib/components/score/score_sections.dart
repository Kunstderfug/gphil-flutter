// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_section.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:provider/provider.dart';

class ScoreSections extends StatelessWidget {
  final List<SetupSection> sections;
  const ScoreSections({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoreProvider>(builder: (context, provider, child) {
      return Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          for (var section in sections)
            ScoreSection(
                name: section.name,
                onTap: () =>
                    provider.setCurrentSection(sections.indexOf(section)),
                isSelected: provider.sectionIndex == sections.indexOf(section))
        ],
      );
    });
  }
}
