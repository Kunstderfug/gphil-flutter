import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
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
    return Consumer<PlaylistProvider>(builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //start time
            Text(
              convertDuration(provider.currentPosition),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),

            // shuffle icon
            IconButton(onPressed: () {}, icon: const Icon(Icons.shuffle)),

            //repeat icon
            IconButton(onPressed: () {}, icon: const Icon(Icons.repeat)),

            //end time
            Text(
              convertDuration(provider.totalDuration),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ],
        ),
      );
    });
  }
}
