import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PlayerHeader extends StatelessWidget {
  final String sectionName;
  const PlayerHeader({super.key, required this.sectionName});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context, listen: false);
    final p = Provider.of<PlaylistProvider>(context);

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //back button
          IconButton(
            iconSize: iconSizeMd,
            padding: const EdgeInsets.all(paddingMd),
            tooltip: 'Back to Score',
            onPressed: () {
              if (p.isPlaying) {
                p.stop();
              }
              n.setNavigationIndex(2);
            },
            icon: const Icon(Icons.arrow_back),
          ),

          //song name
          SizedBox(
            height: 68,
            width: 600,
            child: p.currentSection!.autoContinueMarker != null
                ? Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Text(
                        sectionName,
                        style: TextStyles().textXl,
                      ),
                      Positioned(
                        top: 38,
                        child: Text(
                          "Auto-continue",
                          style: TextStyle(
                              fontSize: fontSizeLg, color: greenColor),
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
            iconSize: iconSizeMd,
            padding: const EdgeInsets.all(paddingMd),
            tooltip: 'Menu',
            onPressed: () {},
            icon: const Icon(Icons.menu),
          ),
        ]);
  }
}
