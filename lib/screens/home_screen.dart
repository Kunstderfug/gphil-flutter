import 'dart:developer';

import 'package:gphil/components/drawer.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/models/song.dart';
import 'package:gphil/screens/song_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final dynamic playlistProvider;

  @override
  void initState() {
    super.initState();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  void goToSong(int songIndex) {
    // update current song index
    playlistProvider.currentSongIndex = songIndex;
    final Song song = playlistProvider.playlist[songIndex];
    log('current song index: ${playlistProvider.currentSongIndex}');
    // go to song screen
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SongPage(
                songName: song.songName, artistName: song.artistName)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text(
            'P L A Y L I S T',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          toolbarHeight: 64,
        ),
        drawer: const MyDrawer(),
        body: Consumer<PlaylistProvider>(builder: (context, provider, child) {
//get the playlist
          final List<Song> playlist = provider.playlist;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: playlist.length,
              itemBuilder: (context, index) {
                final Song song = playlist[index];
                return ListTile(
                    title: Text(song.songName),
                    subtitle: Text(
                      song.artistName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    leading: Image.asset(
                      song.albumArtImagePath,
                      width: 200,
                      height: 200,
                      scale: 1.5,
                      isAntiAlias: true,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.fitHeight,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      // colorBlendMode: BlendMode.colorBurn,
                    ),
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: 4),
                    contentPadding: const EdgeInsets.all(16),
                    onTap: () => goToSong(index));
              },
            ),
          );
        }));
  }
}
