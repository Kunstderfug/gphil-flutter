// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gphil/components/performance/performance_section.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceSections extends StatelessWidget {
  final List<Section> sections;
  const PerformanceSections({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);

    TextStyle style = TextStyle(fontSize: fontSizeSm);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(flex: 3, child: Text('Name', style: style)),
            Expanded(flex: 2, child: Center(child: Text('Loop', style: style))),
            Expanded(
                flex: 2,
                child: Center(child: Text('Auto-cont.', style: style))),
          ]),
        ),
        SizedBox(height: sizeMd),
        for (Section section in sections)
          PerformanceSection(
            section: section,
            onTap: () => p.setCurrentSectionByKey(section.key),
            color: p.setColor().withOpacity(0.2),
            isSelected: p.currentSectionKey == section.key,
          ),
      ],
    );
  }
}
