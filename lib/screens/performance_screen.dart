import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/main_area.dart';
import 'package:gphil/components/performance/playlist_empty.dart';
import 'package:gphil/components/standart_button.dart';
import 'package:gphil/components/tablet_body.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final n = Provider.of<NavigationProvider>(context);

    Widget layout = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 900) {
          return SingleChildScrollView(
            child: MainArea(),
          );
        } else {
          return TabletBody();
        }
      },
    );

    if (p.playlist.isEmpty) {
      return const PlaylistIsEmpty();
    } else {
      return p.filesDownloading
          ? Column(
              children: [
                LoadingFiles(
                  filesLoaded: p.filesDownloaded,
                  filesLength: p.playlist.length,
                ),
                SizedBox(height: separatorXs),
                StandartButton(
                  label: 'Cancel',
                  onPressed: () {
                    p.filesDownloading = false;
                    n.setScoreScreen();
                  },
                ),
              ],
            )
          : p.isLoading
              ? Column(
                  children: [
                    LoadingFiles(
                      filesLoaded: p.filesLoaded,
                      filesLength: p.playlist.length,
                    ),
                    SizedBox(height: separatorXs),
                    StandartButton(
                      label: 'Cancel',
                      onPressed: () {
                        p.filesDownloading = false;
                        n.setScoreScreen();
                      },
                    ),
                    if (kDebugMode)
                      SizedBox(
                        height: 500,
                        width: 500,
                        child: Column(
                          children: [
                            SizedBox(height: separatorMd),
                            Text('filesLoaded: ${p.filesLoaded}'),
                            Text('layerFilesLoaded: ${p.layerFilesLoaded}'),
                            Text('totalLayerFiles: ${p.totalLayerFiles}'),
                            Text(
                                'layerFilesDownloaded: ${p.layerFilesDownloaded}'),
                            Text('filesDownloaded: ${p.filesDownloaded}'),
                          ],
                        ),
                      ),
                  ],
                )
              : layout;
    }
  }
}
