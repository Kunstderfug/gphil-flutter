import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/performance/tooltip_toggle.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';

class PerformanceMode extends StatelessWidget {
  final PlaylistProvider p;
  const PerformanceMode({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return TooltipToggle(
      message:
          'When enabled, skipped and looped section settings will be disregarded\nand the playlist will play through from the beginning to the end.\nAuto-continue settings will be respected.\nThis mode is useful for live performances or run throughs.\nKeyboard shortcut [P]',
      child: AutoSwitch(
          p: p,
          onToggle: (value) => p.setPerformanceMode = value,
          label: 'Performance mode',
          isLarge: true,
          value: p.performanceMode,
          opacity: 1,
          spacing: sizeMd,
          scale: 1),
    );
  }
}
