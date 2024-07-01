import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';

class MixerInfo extends StatelessWidget {
  final PlaylistProvider p;
  const MixerInfo({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    final LayerPlayerPool? currentPool = p.currentLayerPlayerPool;
    final pools = p.layerPlayersPool.globalPools;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.start,
          children: [
            const Text('globalLayers: '),
            for (Layer layer in p.layerPlayersPool.globalLayers)
              Text(layer.layerName),
          ],
        ),
        Text('LayerPool length: ${pools.length.toString()}'),
        Wrap(
          alignment: WrapAlignment.start,
          children: [
            Text('sectionIndex: ${currentPool?.sectionIndex.toString()}, '),
            Text('sectioKey: ${currentPool?.sectionKey}, '),
          ],
        ),
        Wrap(
          children: [
            const Text('poolLayers: '),
            if (p.currentLayerPlayerPool != null)
              for (final layer in p.currentLayerPlayerPool!.layers)
                Text(layer.layer),
          ],
        ),

        //VOLUMES
        Wrap(children: [
          const Text('layerPlayerVolumes: '),
          if (currentPool != null)
            for (final pool in currentPool.players)
              Text('${pool.playerVolume.toString()}, '),
        ]),
        //LAYERS
        Wrap(children: [
          const Text('layers: '),
          if (currentPool != null)
            for (final pool in currentPool.layerChannels)
              Text('${pool.name}, '),
        ]),
      ],
    );
  }
}
