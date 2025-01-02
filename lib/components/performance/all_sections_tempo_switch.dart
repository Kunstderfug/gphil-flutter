import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/performance/tooltip_toggle.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class AllSectionsTempoSwitch extends StatelessWidget {
  const AllSectionsTempoSwitch({super.key});

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
            child: Selector<PlaylistProvider, bool>(
              selector: (_, provider) => provider.tempoForAllSectionsEnabled,
              builder: (context, tempoForAllSectionsEnabled, _) {
                return AutoSwitch(
                  onToggle: (value) => Provider.of<PlaylistProvider>(
                    context,
                    listen: false,
                  ).tempoForAllSections(value),
                  label: 'Change tempo for all sections',
                  value: tempoForAllSectionsEnabled,
                  opacity: 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
