import 'package:flutter/material.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';

class DebugInfo extends StatelessWidget {
  const DebugInfo({super.key, required this.p});

  final PlaylistProvider p;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      child: Column(
        children: [
          SizedBox(height: separatorMd),
          Text('filesLoaded: ${p.filesLoaded}'),
          Text('layerFilesLoaded: ${p.layerFilesLoaded}'),
          Text('totalLayerFiles: ${p.totalLayerFiles}'),
          Text('layerFilesDownloaded: ${p.layerFilesDownloaded}'),
          Text('filesDownloaded: ${p.filesDownloaded}'),
          Text(
              'currentPlaylistDurations: ${p.currentPlaylistDurations.length}'),
          Wrap(
            children: p.playlist
                .map((section) =>
                    Text('Section index: ${section.sectionIndex}, '))
                .toList(),
          ),
          // Wrap(
          //   children: p.playlistClickData
          //       .expand((data) =>
          //           data.clickData.map((click) => Text('${click.time}, ')))
          //       .toList(),
          // ),
        ],
      ),
    );
  }
}
