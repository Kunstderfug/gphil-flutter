import 'package:flutter/material.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PlaylistControl extends StatelessWidget {
  const PlaylistControl({super.key});

  String convertDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, p, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //start time
          Text(
            convertDuration(p.currentPosition),
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),

          // mark in a loop icon
          Opacity(
            opacity: !p.performanceMode ? 1 : 0.3,
            child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    !p.performanceMode ? p.toggleSectionLooped() : null,
                icon: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: p.isSectionLooped
                          ? p.setColor()
                          : Colors.transparent),
                  padding: const EdgeInsets.all(paddingMd),
                  child: const Icon(Icons.loop),
                )),
          ),

          //stop icon
          IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => p.stop(),
              icon: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: p.isPlaying ? p.setColor() : Colors.transparent),
                padding: const EdgeInsets.all(paddingMd),
                child: const Icon(Icons.stop),
              )),

          //end time
          Text(
            convertDuration(p.duration),
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
        ],
      );
    });
  }
}
