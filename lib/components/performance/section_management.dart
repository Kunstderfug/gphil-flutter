import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/performance/tooltip_toggle.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';

class SectionManagement extends StatelessWidget {
  final PlaylistProvider p;
  const SectionManagement({super.key, required this.p});
  final int items = 3;
  final double opacity = 0.4;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: paddingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TooltipToggle(
            message:
                'If enabled, will skip this section in Practice mode.\n Will be ignored in Performance mode.\nKeyboard shortcut [S]',
            child: AutoSwitch(
              p: p,
              onToggle: (value) => !p.performanceMode
                  ? p.toggleSectionSkipped(p.currentSectionKey!)
                  : null,
              label: 'Section skipped',
              value: p.currentSection?.muted ?? false,
              opacity: !p.performanceMode ? 1 : opacity,
            ),
          ),
          TooltipToggle(
            message:
                'If enabled, section will repeatedly play in Practice Mode.\nWhen Performance Mode is enabled, this setting will be ignored.\nKeyboard shortcut [L]',
            child: AutoSwitch(
              p: p,
              onToggle: (value) =>
                  !p.performanceMode ? p.toggleSectionLooped() : null,
              label: 'Section looped',
              value: p.currentSection?.looped ?? false,
              opacity: !p.performanceMode ? 1 : opacity,
            ),
          ),
          TooltipToggle(
            message:
                'Set current section auto-continue on/off.\nKeyboard shortcut [A]',
            child: AutoSwitch(
              p: p,
              onToggle: (value) => p.currentSection?.autoContinue != null
                  ? p.setCurrentSectionAutoContinue()
                  : null,
              label: 'Section auto-continue',
              value: p.currentSection?.autoContinueMarker != null &&
                      p.currentSection?.autoContinue != null
                  ? p.currentSection!.autoContinue!
                  : false,
              opacity:
                  p.currentSection!.autoContinueMarker != null ? 1 : opacity,
            ),
          ),
        ],
      ),
    );
  }
}
