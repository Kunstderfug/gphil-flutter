import 'package:flutter/material.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/providers/playlist_provider.dart';

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
        Text('LayerPool length: ${pools.length.toString()}'),
        Wrap(
          children: [
            const Text('poolLayers: '),
            if (p.currentLayerPlayerPool != null)
              for (final layer in p.currentLayerPlayerPool!.layers)
                Text(layer.layer),
          ],
        ),
        //LAYERS
        Wrap(children: [
          const Text('layers: '),
          if (currentPool != null)
            for (final pool in currentPool.layerChannels)
              Text('${pool.name}, '),
        ]),
        Text('pool current tempo: ${currentPool?.tempo ?? 'no tempo'}'),
      ],
    );
  }
}
