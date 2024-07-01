import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/layer_channel.dart';
import 'package:gphil/components/performance/layer_toggle.dart';
import 'package:gphil/components/performance/main_volume.dart';
import 'package:gphil/components/performance/mixer_info.dart';
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
                  !p.layersEnabled && p.currentSection?.layers != null
                      ? Row(
                          children: [
                            for (Layer layer in p.layerPlayersPool.globalLayers)
                              Opacity(
                                opacity: 0.5,
                                child: LayerChannelLevel(
                                  channelName: layer.fullName,
                                ),
                              ),
                          ],
                        )
                      : Row(
                          children: [
                            for (LayerChannel layer
                                in p.currentLayerPlayerPool?.layerChannels ??
                                    [])
                              Opacity(
                                opacity: layer.player.isActive ? 1 : 0.5,
                                child: LayerChannelLevel(
                                  channelName: layer.name,
                                  layerChannel: layer,
                                ),
                              ),
                          ],
                        ),
                ],
              ),
            ],
          ),
        ),
        p.layerFilesLoading && p.layerFilesLoaded != 0
            ? LoadingAudioFiles(
                filesLoaded: p.filesLoaded, filesLength: p.playlist.length)
            : const SizedBox(
                height: separatorLg,
              ),
        MixerInfo(p: p)
      ],
    );
  }
}
