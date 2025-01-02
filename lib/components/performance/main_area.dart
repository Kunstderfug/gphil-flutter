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
    return Column(
        //Header
        children: [
          // Listen only to current section name
          Selector<PlaylistProvider, String?>(
            selector: (_, p) => p.currentSection?.name,
            builder: (context, sectionName, _) {
              return PlayerHeader(sectionName: sectionName ?? '');
            },
          ),

          const SizedBox(
            height: separatorMd,
          ),

          //Section name and playlist control
          SkippableWidget(
            child: SectionNamePlaylistControl(separatorWidth: separatorWidth),
          ),
          //Separator line and player progress bar
          SkippableWidget(
            child: SeparatorAndProgressBar(
                separatorWidth: separatorWidth, height: 40),
          ),

          //Modes and player control
          SkippableWidget(
            child: ModesAndPlayerControl(
                separatorWidth: separatorWidth, height: 184),
          ),

          const SizedBox(height: 8),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(child: SeparatorLine(height: separatorSm)),
            SizedBox(width: separatorWidth),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SeparatorLine(height: separatorSm),
            )),
          ]),

          //Section management, section image and mixer
          SectionManagementMixer(separatorWidth: separatorWidth),
          const SizedBox(
            height: separatorMd,
          ),
        ]);
  }
}

class SkippableWidget extends StatelessWidget {
  const SkippableWidget({
    super.key,
    required this.child,
    this.duration = 300,
  });

  final Widget child;
  final int duration;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistProvider, bool>(
      selector: (_, p) => p.isSkippingActive,
      builder: (context, isSkippingActive, child) {
        return AnimatedOpacity(
          opacity: isSkippingActive ? globalDisabledOpacity : 1,
          duration: Duration(milliseconds: duration),
          child: child,
        );
      },
      child: child,
    );
  }
}
