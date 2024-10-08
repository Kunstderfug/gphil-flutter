// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gphil/components/performance/performance_section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceSections extends StatelessWidget {
  final List<Section> sections;
  const PerformanceSections({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    TextStyle style = TextStyle(fontSize: fontSizeSm);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(flex: 3, child: Text('Section', style: style)),
            Expanded(flex: 2, child: Center(child: Text('Skip', style: style))),
            Expanded(flex: 2, child: Center(child: Text('Loop', style: style))),
            Expanded(flex: 2, child: Center(child: Text('Auto', style: style))),
          ]),
        ),
        SizedBox(height: sizeMd),
        Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withOpacity(0.7),
            ),
            child: Column(children: [
              for (Section section in sections)
                PerformanceSection(
                  section: section,
                  onTap: () => p.setCurrentSectionByKey(section.key),
                  isSelected: p.currentSectionKey == section.key,
                ),
            ])),
      ],
    );
  }
}
