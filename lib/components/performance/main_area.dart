import 'package:flutter/material.dart';
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
    return Column(
        //Header
        children: [
          PlayerHeader(sectionName: p.currentSection?.name ?? ''),

          const SizedBox(
            height: separatorMd,
          ),

          //Section name and playlist control
          SectionNamePlaylistControl(separatorWidth: separatorWidth),

          //Separator line and player progress bar
          SeparatorAndProgressBar(separatorWidth: separatorWidth, height: 60),

          //Modes and player control
          ModesAndPlayerControl(separatorWidth: separatorWidth, height: 184),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(child: SeparatorLine(height: separatorLg)),
            SizedBox(width: separatorWidth),
            Expanded(child: SeparatorLine(height: separatorLg)),
          ]),

          //Section management and mixer
          SectionManagementMixer(separatorWidth: separatorWidth)
        ]);
  }
}
