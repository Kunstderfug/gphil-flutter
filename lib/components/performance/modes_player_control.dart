import 'package:flutter/material.dart';
import 'package:gphil/components/performance/all_sections_tempo_switch.dart';
import 'package:gphil/components/performance/one_pedal_mode_switch.dart';
import 'package:gphil/components/player/player_control.dart';
import 'package:gphil/components/score/section_tempos.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ModesAndPlayerControl extends StatelessWidget {
  final double separatorWidth;
  final double height;
  const ModesAndPlayerControl(
      {super.key, required this.separatorWidth, required this.height});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final n = Provider.of<NavigationProvider>(context);

    return SizedBox(
      height: height,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //RIGHT SIDE, MODES and section tempos
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: paddingMd),
                        child: OnePedalMode(p: p),
                      ),
                      if (n.isPerformanceScreen && p.areAllTempoRangesEqual)
                        AllSectionsTempoSwitch(p: p),
                    ],
                  ),
                  SizedBox(
                    height: 26,
                  ),
                  if (p.currentSection != null)
                    SectionTempos(section: p.currentSection!),
                ],
              ),
            ),
            //Separator
            SizedBox(
              width: separatorWidth,
            ),

            //RIGHT SIDE, PLAYER CONTROLS
            Expanded(
              child: Opacity(
                  opacity: p.appState == AppState.loading ? 0.5 : 1,
                  child: const PlayerControl()),
            )
          ]),
    );
  }
}
