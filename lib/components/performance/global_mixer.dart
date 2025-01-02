import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/layer_channel.dart';
import 'package:gphil/components/performance/layer_toggle.dart';
import 'package:gphil/components/performance/main_volume.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/models/score.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class MixerState {
  final AppState appState;
  final GlobalLayerPlayerPool layerPlayersPool;
  final bool layersEnabled;
  final Section? currentSection;
  final Score? sessionScore;
  final Color Function() setColor;

  const MixerState({
    required this.appState,
    required this.layerPlayersPool,
    required this.layersEnabled,
    required this.currentSection,
    required this.sessionScore,
    required this.setColor,
  });
}

class GlobalMixer extends StatelessWidget {
  const GlobalMixer({super.key});

  Widget _buildLoadingIndicator(GlobalLayerPlayerPool pool, List playlist) {
    return Center(
      child: Align(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: LoadingFiles(
            filesLoaded: pool.globalPools.length,
            filesLength: playlist.where((s) => s.layers != null).length,
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton(
      BuildContext context, bool layersEnabled, Color color) {
    return Opacity(
      opacity: layersEnabled ? 1 : globalDisabledOpacity,
      child: IconButton(
        tooltip: 'Reset mixer',
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.hovered) && layersEnabled) {
                return color.withValues(alpha: 0.2);
              }
              return null;
            },
          ),
          foregroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.onSurface,
          ),
          iconColor: WidgetStatePropertyAll(color),
        ),
        onPressed: () => layersEnabled
            ? Provider.of<PlaylistProvider>(context, listen: false).resetMixer()
            : null,
        icon: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildLayerChannels(
    bool layersEnabled,
    Section? currentSection,
    List<Layer> layers,
  ) {
    return Row(
      spacing: paddingMd,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (Layer layer in layers)
          Opacity(
            opacity: layersEnabled && currentSection?.layers != null ? 1 : 0.3,
            child: LayerChannelLevel(layer: layer),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistProvider, MixerState>(
      selector: (_, provider) => MixerState(
        appState: provider.appState,
        layerPlayersPool: provider.layerPlayersPool,
        layersEnabled: provider.layersEnabled,
        currentSection: provider.currentSection,
        sessionScore: provider.sessionScore,
        setColor: provider.setColor,
      ),
      builder: (context, state, _) {
        final playlist =
            Provider.of<PlaylistProvider>(context, listen: false).playlist;

        return Stack(
          children: [
            Column(
              children: [
                const Text(
                  'M I X E R (experimental)',
                  style: TextStyle(fontSize: fontSizeLg),
                ),
                SizedBox(
                  height: 40,
                  child: state.appState == AppState.loading &&
                          state.layerPlayersPool.globalPools.isNotEmpty
                      ? _buildLoadingIndicator(state.layerPlayersPool, playlist)
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: SizedBox(),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const MainVolume(),
                    const SizedBox(width: separatorXl),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildResetButton(
                                      context,
                                      state.layersEnabled,
                                      state.setColor(),
                                    ),
                                    const LayerToggleSwitch(),
                                  ],
                                ),
                                if (state.sessionScore?.globalLayers != null)
                                  _buildLayerChannels(
                                    state.layersEnabled,
                                    state.currentSection,
                                    state.layerPlayersPool.globalLayers
                                            .isNotEmpty
                                        ? state.layerPlayersPool.globalLayers
                                        : defaultMixer,
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
      },
    );
  }
}
