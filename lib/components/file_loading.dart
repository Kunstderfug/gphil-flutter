import 'package:flutter/material.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LoadingLayerFiles extends StatelessWidget {
  final int filesLoaded;
  final int filesLength;
  const LoadingLayerFiles(
      {super.key, required this.filesLoaded, required this.filesLength});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, child) {
        return Visibility(
          visible: true,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('loading files...'),
              ),
              LinearProgressIndicator(
                minHeight: 4,
                color: highlightColor,
                backgroundColor: highlightColor.withOpacity(0.5),
                value: (filesLoaded / filesLength).toDouble(),
              ),
            ],
          ),
        );
      },
    );
  }
}
