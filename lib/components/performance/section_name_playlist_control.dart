import 'package:flutter/material.dart';
import 'package:gphil/components/player/playlist_control.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionNamePlaylistControl extends StatelessWidget {
  final double separatorWidth;
  const SectionNamePlaylistControl({super.key, required this.separatorWidth});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      //RIGHT SIDE, SECTION NAME
      Expanded(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Flexible(
            child: Center(
              child: Text(p.currentSection!.name.replaceAll('_', ' '),
                  style: TextStyles().textLg),
            ),
          ),
          Flexible(
            child: Center(
              child: Text(
                p.currentSection!.autoContinueMarker != null
                    ? 'Auto-Continue'
                    : '',
                style: TextStyle(
                    fontSize: fontSizeLg,
                    fontWeight: FontWeight.bold,
                    color: p.currentSection!.autoContinue != false
                        ? greenColor
                        : Colors.grey.shade700),
              ),
            ),
          ),
        ]),
      ),
      //Separator
      SizedBox(
        width: separatorWidth,
      ),

      //RIGHT SIDE, PLAYLIST CONTROLS
      Expanded(
        child: RepaintBoundary(
          child: const PlaylistControl(),
        ),
      )
    ]);
  }
}
