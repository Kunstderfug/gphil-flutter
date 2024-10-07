import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/performance/tooltip_toggle.dart';
import 'package:gphil/providers/playlist_provider.dart';

class AllSectionsTempoSwitch extends StatelessWidget {
  final PlaylistProvider p;
  const AllSectionsTempoSwitch({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TooltipToggle(
          message:
              'If enabled, a tempo change will affect all sections in the current movement\nOnly available in movements with identical tempo set for all section',
          child: AutoSwitch(
            p: p,
            onToggle: (value) => p.tempoForAllSections(value),
            label: 'Change tempo for all sections',
            value: p.tempoForAllSectionsEnabled,
            opacity: 1,
          ),
        ),
      ],
    ));
  }
}
