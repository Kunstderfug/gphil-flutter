import 'package:gphil/components/neo.dart';
import 'package:gphil/models/playlist_provider.dart';
// import 'package:gphil/models/song.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SongPage extends StatelessWidget {
  final String songName;
  final String artistName;
  const SongPage({super.key, required this.songName, required this.artistName});

  // convert duration to min:sec
  String convertDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, provider, child) {
      //get the playlist

      return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // custom app bar
                SafeArea(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //back button
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),

                        //song name
                        Text(
                          '$songName - $artistName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        //menu button
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.menu),
                        ),
                      ]),
                ),
                const SizedBox(
                  height: 25,
                ),
                // album artwork
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Neo(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            provider.playlist[provider.currentSongIndex!]
                                .albumArtImagePath,
                            isAntiAlias: true,
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.cover,
                            width: 300,
                            height: 300,
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //start time
                      Text(
                        convertDuration(provider.currentPosition),
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),

                      // shuffle icon
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.shuffle)),

                      //repeat icon
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.repeat)),

                      //end time
                      Text(
                        convertDuration(provider.totalDuration),
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inversePrimary),
                      ),
                    ],
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 0,
                  )),
                  child: Slider(
                    min: 0,
                    max: provider.totalDuration.inMilliseconds.toDouble(),
                    value: provider.currentPosition.inMilliseconds.toDouble(),
                    activeColor: Colors.teal.shade300,
                    onChanged: (double value) {},
                    onChangeEnd: (double value) {
                      provider.seek(Duration(seconds: (value ~/ 1000).toInt()));
                    },
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //previous button
                      Expanded(
                        child: Neo(
                          child: IconButton(
                              onPressed: provider.playPreviousSong,
                              icon: const Icon(Icons.skip_previous)),
                        ),
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      //play button
                      Expanded(
                        flex: 2,
                        child: Neo(
                          child: IconButton(
                              onPressed: provider.pauseOrResume,
                              icon: Icon(provider.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow)),
                        ),
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      //next button
                      Expanded(
                        child: Neo(
                          child: IconButton(
                              onPressed: provider.playNextSong,
                              icon: const Icon(Icons.skip_next)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ));
    });
  }
}
