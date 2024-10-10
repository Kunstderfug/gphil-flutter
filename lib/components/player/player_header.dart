import 'package:flutter/material.dart';
import 'package:gphil/components/performance/performance_mode.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PlayerHeader extends StatelessWidget {
  final String sectionName;
  const PlayerHeader({super.key, required this.sectionName});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context, listen: false);
    final p = Provider.of<PlaylistProvider>(context);
    final s = Provider.of<ScoreProvider>(context, listen: false);

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      //back button
      IconButton(
        iconSize: iconSizeXs,
        padding: const EdgeInsets.all(paddingSm),
        tooltip: 'Back to Score',
        onPressed: () async {
          if (p.isPlaying) {
            p.stop();
            await p.player.disposeAllSources();
          }
          if (s.currentScore!.id != p.sessionScore!.id) {
            await s.getScore(p.sessionScore!.id);
          }
          s.setSections(p.currentMovementKey!, p.currentSection!.key);
          s.setCurrentSectionByKey(
              p.currentMovementKey!, p.currentSection!.key);
          // s.setCurrentTempo(p.currentTempo!);
          n.setCurrentIndex(2);
          n.setSelectedIndex(0);
        },
        icon: const Icon(Icons.arrow_back),
      ),

      //Performance mode switch
      PerformanceMode(p: p),
    ]);
  }
}
