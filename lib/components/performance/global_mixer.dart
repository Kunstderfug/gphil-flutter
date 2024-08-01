import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/layer_channel.dart';
import 'package:gphil/components/performance/layer_toggle.dart';
import 'package:gphil/components/performance/main_volume.dart';
// import 'package:gphil/components/performance/mixer_info.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';

class GlobalMixer extends StatelessWidget {
  final PlaylistProvider p;
  const GlobalMixer({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'M I X E R (experimental)',
          style: TextStyle(
            fontSize: fontSizeLg,
          ),
        ),
        const SizedBox(
          height: separatorMd,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700, minWidth: 611),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const MainVolume(),
              const SizedBox(
                width: separatorMd,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  LayerToggleSwitch(p: p),
                  Row(
                    children: [
                      for (Layer layer
                          in (p.layerPlayersPool.globalLayers.isNotEmpty
                              ? p.layerPlayersPool.globalLayers
                              : defaultMixer))
                        Opacity(
                          opacity: p.layersEnabled &&
                                  p.currentSection?.layers != null
                              ? 1
                              : 0.3,
                          child: LayerChannelLevel(layer: layer),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: separatorXl,
          width: 500,
          child: p.layerFilesLoading
              ? LoadingLayerFiles(
                  filesLoaded: p.layerPlayersPool.globalPools.length,
                  filesLength: p.playlist.where((s) => s.layers != null).length)
              : null,
        ),
        // MixerInfo(p: p),
      ],
    );
  }
}

// p.layerPlayersPool.globalPools.length /
//                         p.playlist.where((s) => s.layers != null).length >
//                     1
//                 ? 