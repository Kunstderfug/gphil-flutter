import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/performance/tooltip_toggle.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';

class SectionManagement extends StatelessWidget {
  final PlaylistProvider p;
  const SectionManagement({super.key, required this.p});
  final int items = 3;

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
                'If enabled, will skip this section in Practice mode.\n Will be ignored in Performance mode.\nKeyboard shortcut [M]',
            child: AutoSwitch(
              p: p,
              onToggle: (value) => p.toggleSectionSkipped(p.currentSectionKey!),
              label: 'Section skipped',
              value: p.currentSection?.muted ?? false,
              opacity: 1,
            ),
          ),
          Opacity(
            opacity: !p.performanceMode ? 1 : 0.4,
            child: TooltipToggle(
              message:
                  'If enabled, section will repeatedly play in Practice Mode.\nWhen Performance Mode is enabled, this setting will be ignored.\nKeyboard shortcut [L]',
              child: AutoSwitch(
                p: p,
                onToggle: (value) =>
                    !p.performanceMode ? p.toggleSectionLooped() : null,
                label: 'Section looped',
                value: p.currentSection?.looped ?? false,
                opacity: 1,
              ),
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
              opacity: p.currentSection!.autoContinueMarker != null ? 1 : 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
