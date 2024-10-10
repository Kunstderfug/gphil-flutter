import 'package:flutter/material.dart';
import 'package:gphil/components/performance/performance_movements.dart';
import 'package:gphil/components/performance/performance_sections.dart';
import 'package:gphil/components/performance/section_colorizer.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class PerformanceSidebar extends StatelessWidget {
  const PerformanceSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
        child: PerformanceMovements(movements: p.sessionMovements),
      ),
      Expanded(child: PerformanceSections(sections: p.currentMovementSections)),
      SectionColorizer(),
    ]);
  }
}
