// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gphil/components/performance/performance_section.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceSections extends StatelessWidget {
  final List<Section> sections;
  const PerformanceSections({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(fontSize: fontSizeSm);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 14),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(flex: 2, child: Text('Section', style: style)),
            Expanded(
              flex: 3,
              child: Row(children: [
                Expanded(
                    flex: 1, child: Center(child: Text('Skip', style: style))),
                Expanded(
                    flex: 1, child: Center(child: Text('Loop', style: style))),
                Expanded(
                    flex: 1, child: Center(child: Text('Auto', style: style))),
              ]),
            )
          ]),
        ),
        const SizedBox(height: sizeMd),
        Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900.withValues(alpha: 0.7),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (Section section in sections)
                Selector<PlaylistProvider, String?>(
                  selector: (_, provider) => provider.currentSectionKey,
                  builder: (context, currentSectionKey, _) {
                    return PerformanceSection(
                      section: section,
                      onTap: () async => context
                          .read<PlaylistProvider>()
                          .setOrPlaySelectedSection(section.key),
                      isSelected: currentSectionKey == section.key,
                    );
                  },
                ),
            ])),
      ],
    );
  }
}
