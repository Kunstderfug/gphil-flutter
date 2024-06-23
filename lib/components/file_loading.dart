import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class FileLoading extends StatelessWidget {
  const FileLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, provider, child) {
        return Visibility(
          visible: true,
          child: Padding(
              padding: const EdgeInsets.all(64),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('loading files...'),
                  ),
                  LinearProgressIndicator(
                    minHeight: 4,
                    color: const Color.fromARGB(255, 159, 33, 243),
                    value: provider.filesLoaded / provider.playlist.length,
                  ),
                ],
              )),
        );
      },
    );
  }
}
