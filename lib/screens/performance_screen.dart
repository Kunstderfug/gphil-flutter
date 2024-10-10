import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/laptop_body.dart';
import 'package:gphil/components/performance/playlist_empty.dart';
import 'package:gphil/components/tablet_body.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    Widget layout = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth >= 900) {
        return Center(child: SingleChildScrollView(child: LaptopBody()));
      } else {
        return TabletBody();
      }
    });

    if (p.playlist.isEmpty) {
      return const PlaylistIsEmpty();
    } else {
      return p.filesDownloading
          ? LoadingFiles(
              filesLoaded: p.filesDownloaded, filesLength: p.playlist.length)
          : p.isLoading
              ? LoadingFiles(
                  filesLoaded: p.filesLoaded, filesLength: p.playlist.length)
              : layout;
    }
  }
}
