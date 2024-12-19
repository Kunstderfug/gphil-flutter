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
            SizedBox(
              height: 40,
              child: p.appState == AppState.loading &&
                      p.layerPlayersPool.globalPools.isNotEmpty
                  ? Center(
                      child: Align(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 300),
                          child: LoadingFiles(
                              filesLoaded:
                                  p.layerPlayersPool.globalPools.length,
                              filesLength: p.playlist
                                  .where((s) => s.layers != null)
                                  .length),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: const SizedBox(),
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const MainVolume(),
                const SizedBox(
                  width: separatorXl,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Opacity(
                                  opacity: p.layersEnabled
                                      ? 1
                                      : globalDisabledOpacity,
                                  child: IconButton(
                                    tooltip: 'Reset mixer',
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty
                                          .resolveWith<Color?>(
                                        (Set<WidgetState> states) {
                                          if (states.contains(
                                                  WidgetState.hovered) &&
                                              p.layersEnabled) {
                                            return p
                                                .setColor()
                                                .withValues(alpha: 0.2);
                                          }
                                          return null;
                                        },
                                      ),
                                      foregroundColor: WidgetStatePropertyAll(
                                          Theme.of(context)
                                              .colorScheme
                                              .onSurface),
                                      iconColor:
                                          WidgetStatePropertyAll(p.setColor()),
                                      // side: WidgetStatePropertyAll(
                                      //   BorderSide(
                                      //     color: p.setColor(),
                                      //   ),
                                      // ),
                                    ),
                                    onPressed: () =>
                                        p.layersEnabled ? p.resetMixer() : null,
                                    icon: const Icon(Icons.refresh),
                                  ),
                                ),
                                LayerToggleSwitch(p: p),
                              ],
                            ),
                            if (p.sessionScore?.globalLayers != null)
                              Row(
                                spacing: paddingXl,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  for (Layer layer in (p.layerPlayersPool
                                          .globalLayers.isNotEmpty
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
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
