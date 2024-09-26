import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';

class SectionAutoContinueSwitch extends StatelessWidget {
  final PlaylistProvider p;
  const SectionAutoContinueSwitch({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: separatorLg * 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AutoSwitch(
              p: p,
              onToggle: (value) => p.setSectionSkipped(p.currentSectionKey!),
              label: p.currentSection?.muted == true
                  ? 'Section skipped'
                  : 'Skip section',
              value: p.currentSection?.muted ?? false,
              opacity: 1,
            ),
            AutoSwitch(
              p: p,
              onToggle: (value) => p.currentSection?.autoContinue != null
                  ? p.setCurrentSectionAutoContinue()
                  : null,
              label: 'Section auto-continue',
              value: p.currentSection?.autoContinueMarker != null &&
                      p.currentSection?.autoContinue != null
                  ? p.currentSection!.autoContinue!
                  : false,
              opacity: p.currentSection!.autoContinueMarker != null ? 1 : 0.4,
            ),
          ],
        ));
  }
}
