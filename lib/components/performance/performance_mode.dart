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
      message: 'When enabled, Will follow looped sections',
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
