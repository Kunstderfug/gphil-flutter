import 'package:flutter/material.dart';
import 'package:gphil/components/playlist_tile.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/models/song.dart';
import 'package:gphil/screens/song_screen.dart';
import 'package:provider/provider.dart';

class HomePlaylist extends StatefulWidget {
  const HomePlaylist({super.key});

  @override
  State<HomePlaylist> createState() => _HomePlaylistState();
}

class _HomePlaylistState extends State<HomePlaylist> {
  late final dynamic playlistProvider;

  @override
  void initState() {
    super.initState();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  void goToSong(int songIndex) {
    // update current song index
    playlistProvider.currentSongIndex = songIndex;
    // go to song screen
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SongScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, provider, child) {
      //get the playlist
      final List<Song> playlist = provider.playlist;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount(MediaQuery.of(context).size.width),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3 / 1,
          ),
          itemCount: playlist.length,
          itemBuilder: (context, index) {
            final Song song = playlist[index];
            return PlaylistTile(song: song, songIndex: index);
          },
        ),
      );
    });
  }
}

// set up grid view
int gridCount(double pixels) {
  return (pixels / 700).ceil();
}
