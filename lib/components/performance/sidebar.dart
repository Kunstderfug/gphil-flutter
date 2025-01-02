import 'package:flutter/material.dart';
import 'package:gphil/components/performance/performance_movements.dart';
import 'package:gphil/components/performance/performance_sections.dart';
import 'package:gphil/components/performance/section_colorizer.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class PerformanceSidebar extends StatelessWidget {
  const PerformanceSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistProvider, SidebarState>(
      selector: (_, provider) => SidebarState(
        provider.sessionMovements,
        provider.currentMovementSections,
      ),
      builder: (context, state, _) {
        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
              child: PerformanceMovements(movements: state.sessionMovements),
            ),
            Expanded(
              child:
                  PerformanceSections(sections: state.currentMovementSections),
            ),
            if (state.currentMovementSections.isNotEmpty)
              const SectionColorizer(),
          ],
        );
      },
    );
  }
}

class SidebarState {
  final List<SessionMovement> sessionMovements;
  final List<Section> currentMovementSections;

  SidebarState(this.sessionMovements, this.currentMovementSections);
}
