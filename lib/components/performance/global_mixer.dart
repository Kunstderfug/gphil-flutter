import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/layer_channel.dart';
import 'package:gphil/components/performance/layer_toggle.dart';
import 'package:gphil/components/performance/main_volume.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';

class GlobalMixer extends StatelessWidget {
  final PlaylistProvider p;
  const GlobalMixer({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const MainVolume(),
                const SizedBox(
                  width: separatorXl,
                ),
                SizedBox(
                  height: 340,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      LayerToggleSwitch(p: p),
                      if (p.sessionScore?.globalLayers != null)
                        Wrap(
                          spacing: paddingXl,
                          runSpacing: 4,
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
                ),
              ],
            ),
            const SizedBox(
              height: separatorSm,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  p.appState == AppState.loading &&
                          p.layerPlayersPool.globalPools.isNotEmpty
                      ? Align(
                          // alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 300),
                            child: LoadingFiles(
                                filesLoaded:
                                    p.layerPlayersPool.globalPools.length,
                                filesLength: p.playlist
                                    .where((s) => s.layers != null)
                                    .length),
                          ),
                        )
                      : Expanded(child: const SizedBox()),
                  if (p.layersEnabled)
                    Align(
                        alignment: Alignment.topRight,
                        child: TextButton.icon(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return greenColor.withOpacity(
                                        0.2); // Set the background color on hover
                                  }
                                  return null; // Use the default button background color
                                },
                              ),
                              foregroundColor: WidgetStatePropertyAll(
                                  Theme.of(context).colorScheme.onSurface),
                              minimumSize:
                                  const WidgetStatePropertyAll(Size(180, 40)),
                              iconColor: WidgetStatePropertyAll(greenColor),
                              side: WidgetStatePropertyAll(
                                BorderSide(
                                  color: greenColor,
                                ),
                              ),
                            ),
                            onPressed: p.resetMixer,
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              'Reset Mixer',
                              style: TextStyle(
                                  fontSize: fontSizeMd, color: Colors.white),
                            ))),
                ]),
          ],
        ),
      ],
    );
  }
}
