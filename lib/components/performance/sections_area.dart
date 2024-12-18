import 'package:flutter/material.dart';
import 'package:gphil/components/performance/performance_sections.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class SectionsArea extends StatelessWidget {
  const SectionsArea({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    return PerformanceSections(sections: p.currentMovementSections);
  }
}
