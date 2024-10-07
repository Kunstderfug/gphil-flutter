import 'package:flutter/material.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LoadingFiles extends StatelessWidget {
  final int filesLoaded;
  final int filesLength;
  const LoadingFiles(
      {super.key, required this.filesLoaded, required this.filesLength});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, p, child) {
        return Visibility(
          visible: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(p.filesDownloading
                    ? 'getting files ready...'
                    : 'loading files...'),
              ),
              LinearProgressIndicator(
                minHeight: 2,
                color: greenColor,
                backgroundColor: greenColor.withOpacity(0.5),
                value: (filesLoaded / filesLength).toDouble(),
              ),
            ],
          ),
        );
      },
    );
  }
}
