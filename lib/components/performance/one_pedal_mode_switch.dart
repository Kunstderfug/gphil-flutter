import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/performance/tooltip_toggle.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class OnePedalMode extends StatelessWidget {
  const OnePedalMode({super.key});

  @override
  Widget build(BuildContext context) {
    return TooltipToggle(
      message: 'One pedal mode \n(both pedals will start a section)',
      child: SizedBox(
        height: separatorLg,
        child: Selector<PlaylistProvider, bool>(
          selector: (_, provider) => provider.onePedalMode,
          builder: (context, onePedalMode, _) {
            return AutoSwitch(
              onToggle: (value) => Provider.of<PlaylistProvider>(
                context,
                listen: false,
              ).setOnePedalMode(value),
              label: 'One pedal mode',
              value: onePedalMode,
              opacity: 1,
            );
          },
        ),
      ),
    );
  }
}
