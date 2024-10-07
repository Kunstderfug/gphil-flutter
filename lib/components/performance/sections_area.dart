import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_section.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionsArea extends StatelessWidget {
  const SectionsArea({super.key});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);

    Widget wrap = Wrap(
      runSpacing: paddingMd,
      spacing: 0,
      children: [
        for (final section in p.currentMovementSections)
          ScoreSection(
              section: section,
              onTap: () => p.appState == AppState.loading
                  ? null
                  : p.setCurrentSectionByKey(section.key),
              isSelected: p.currentSectionKey == section.key),
      ],
    );

    return n.isPerformanceScreen
        ? LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                constraints.maxWidth >= 1200
                    ? SingleChildScrollView(
                        child: SizedBox(
                          height: 500,
                          child: Wrap(
                            direction: Axis.vertical,
                            runSpacing: paddingMd,
                            spacing: 0,
                            children: [
                              for (int i = 0;
                                  i < p.currentMovementSections.length;
                                  i++)
                                ScoreSection(
                                    section: p.currentMovementSections[i],
                                    onTap: () => p.appState == AppState.loading
                                        ? null
                                        : p.setCurrentSectionByKey(
                                            p.currentMovementSections[i].key),
                                    isSelected: p.currentSectionKey ==
                                        p.currentMovementSections[i].key),
                            ],
                          ),
                        ),
                      )
                    : wrap)
        : wrap;
  }
}
