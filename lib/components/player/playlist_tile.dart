import 'package:flutter/material.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/models/section.dart';
import 'package:provider/provider.dart';

class PlaylistTile extends StatelessWidget {
  final Section section;
  final int sectionIndex;

  const PlaylistTile({
    super.key,
    required this.section,
    required this.sectionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaylistProvider>(context, listen: false);

    return ListTile(
        title: Text(
          section.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 18,
          ),
        ),
        visualDensity: const VisualDensity(horizontal: 0, vertical: 4),
        contentPadding: const EdgeInsets.all(16),
        onTap: () {
          provider.currentSectionIndex = sectionIndex;
          Navigator.pushNamed(context, '/song');
        });
  }
}
