import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';

class OnePedalMode extends StatelessWidget {
  final PlaylistProvider p;
  const OnePedalMode({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: separatorLg,
        child: AutoSwitch(
          p: p,
          onToggle: (value) => p.setOnePedalMode(value),
          label: 'One pedal mode \n(both pedals will start a section)',
          value: p.onePedalMode,
          opacity: 1,
        ));
  }
}
