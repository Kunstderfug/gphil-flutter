import 'package:flutter/material.dart';
import 'package:gphil/components/footer.dart';
import 'package:gphil/components/performance/modes_player_control.dart';
import 'package:gphil/components/performance/section_management_mixer.dart';
import 'package:gphil/components/performance/section_name_playlist_control.dart';
import 'package:gphil/components/performance/separator_progress_bar.dart';
import 'package:gphil/components/player/player_header.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class MainArea extends StatelessWidget {
  const MainArea({super.key});

  final double separatorWidth = sizeXl;

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    double opacity = 0.3;
    int duration = 300;

    return Column(
        //Header
        children: [
          PlayerHeader(sectionName: p.currentSection?.name ?? ''),

          const SizedBox(
            height: separatorMd,
          ),

          //Section name and playlist control
          AnimatedOpacity(
              opacity: p.isSkippingActive ? opacity : 1,
              duration: Duration(milliseconds: duration),
              child:
                  SectionNamePlaylistControl(separatorWidth: separatorWidth)),

          //Separator line and player progress bar
          AnimatedOpacity(
              opacity: p.isSkippingActive ? opacity : 1,
              duration: Duration(milliseconds: duration),
              child: SeparatorAndProgressBar(
                  separatorWidth: separatorWidth, height: 40)),

          //Modes and player control
          AnimatedOpacity(
              opacity: p.isSkippingActive ? opacity : 1,
              duration: Duration(milliseconds: duration),
              child: ModesAndPlayerControl(
                  separatorWidth: separatorWidth, height: 184)),
          SizedBox(height: 8),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(child: SeparatorLine(height: separatorSm)),
            SizedBox(width: separatorWidth),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SeparatorLine(height: separatorSm),
            )),
          ]),

          //Section management and mixer
          SectionManagementMixer(separatorWidth: separatorWidth),
          const SizedBox(
            height: separatorMd,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(child: Center(child: Footer())),
            SizedBox(width: separatorWidth),
            Expanded(child: SizedBox(width: separatorWidth)),
          ]),
        ]);
  }
}
