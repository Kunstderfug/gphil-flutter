import 'package:flutter/material.dart';
// import 'package:gphil/models/layer_player.dart';
import 'package:gphil/providers/playlist_provider.dart';

class MixerInfo extends StatelessWidget {
  final PlaylistProvider p;
  const MixerInfo({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    // final LayerPlayerPool? currentPool = p.currentLayerPlayerPool;
    // final pools = p.layerPlayersPool.globalPools;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Files loaded: ${p.currentlyLoadedFiles.length}'),
                for (String file in p.currentlyLoadedFiles) Text(file),
              ],
            ),
          ),
        ),
        SizedBox(
            height: 200,
            width: 300,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.isPlaying)
                    Text(
                        'Main player volume: ${p.player.getVolume(p.activeHandle!)}'),
                  if (p.currentLayerPlayerPool != null && p.isPlaying)
                    Text(
                        'Layers volume: ${p.currentLayerPlayerPool!.layerChannels[0].player!.playerVolume}'),
                ],
              ),
            )),
      ],
    );
  }
}
