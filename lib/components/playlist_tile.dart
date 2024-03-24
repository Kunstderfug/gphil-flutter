import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/models/song.dart';
import 'package:gphil/screens/song_screen.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatelessWidget {
  final Song song;
  final int songIndex;

  const PlaylistTile({
    super.key,
    required this.song,
    required this.songIndex,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaylistProvider>(context, listen: false);

    return ListTile(
        title: Text(
          song.songName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 18,
          ),
        ),
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
        visualDensity: const VisualDensity(horizontal: 0, vertical: 4),
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          provider.currentSongIndex = songIndex;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SongScreen()));
        });
  }
}
