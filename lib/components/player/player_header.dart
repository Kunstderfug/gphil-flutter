import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
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

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //back button
          IconButton(
            iconSize: iconSizeXs,
            padding: const EdgeInsets.all(paddingSm),
            tooltip: 'Back to Score',
            onPressed: () async {
              if (p.isPlaying) {
                p.stop();
              }
              s.setSections(p.currentMovementKey!, p.currentSection!.key);
              s.setCurrentSection(p.currentSection!.key);
              n.setNavigationIndex(2);
            },
            icon: const Icon(Icons.arrow_back),
          ),

          //song name
          SizedBox(
            height: 48,
            width: 600,
            child: p.currentSection!.autoContinueMarker != null &&
                    p.currentSection!.autoContinue != null
                ? Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Text(
                        sectionName,
                        style: TextStyles().textLg,
                      ),
                      Positioned(
                        top: 28,
                        child: Text(
                          p.currentSection!.autoContinue! != false
                              ? "Auto-continue"
                              : "Auto-continue disabled",
                          style: TextStyle(
                              fontSize: fontSizeMd,
                              color: p.currentSection!.autoContinue! != false
                                  ? greenColor
                                  : Colors.grey.shade700),
                        ),
                      ),
                    ],
                  )
                : Text(
                    sectionName,
                    textAlign: TextAlign.center,
                    style: TextStyles().textXl,
                  ),
          ),

          //menu button
          IconButton(
            iconSize: iconSizeXs,
            padding: const EdgeInsets.all(paddingSm),
            tooltip: 'Menu (for the future actions)',
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
        ]);
  }
}
