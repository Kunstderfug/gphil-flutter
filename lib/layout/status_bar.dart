import 'package:flutter/material.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/app_update_service.dart';
import 'package:provider/provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  bool _ifTempoChanged(ScoreProvider s, PlaylistProvider p) {
    final originalSection = s.allSections
        .firstWhere((section) => section.key == p.currentSectionKey);

    if (originalSection.userTempo != null &&
        originalSection.userTempo != p.currentSection?.userTempo) {
      return true;
    }
    if (originalSection.defaultTempo != p.currentSection?.userTempo) {
      return true;
    }
    return false;
  }

  Widget _buildTempoStatus(BuildContext context, ScoreProvider s) {
    return Selector<
        PlaylistProvider,
        ({
          Section? currentSection,
          bool isLoading,
        })>(
      selector: (_, provider) => (
        currentSection: provider.currentSection,
        isLoading: provider.isLoading,
      ),
      builder: (context, state, _) {
        final p = Provider.of<PlaylistProvider>(context, listen: false);
        return StatusBarItem(
          text: '',
          value: state.currentSection != null && !state.isLoading
              ? 'Default tempo: ${state.currentSection?.defaultTempo.toString()} ${state.currentSection!.userTempo != null ? '| User tempo: ${state.currentSection!.userTempo}${_ifTempoChanged(s, p) ? '*' : ''}' : ''}'
              : 'Not selected',
        );
      },
    );
  }

  Widget _buildPlayerStatus(BuildContext context) {
    return Selector<
        PlaylistProvider,
        ({
          String message,
          bool isLoading,
          double playerVolume,
          bool layersEnabled,
          bool layerFilesLoading,
          GlobalLayerPlayerPool layerPlayersPool,
        })>(
      selector: (_, provider) => (
        message: provider.message,
        isLoading: provider.isLoading,
        playerVolume: provider.playerVolume,
        layersEnabled: provider.layersEnabled,
        layerFilesLoading: provider.layerFilesLoading,
        layerPlayersPool: provider.layerPlayersPool,
      ),
      builder: (context, state, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(state.message, style: textStyle),
            if (!state.isLoading)
              Text(
                '|  Player volume: ${state.playerVolume.toStringAsFixed(2)}',
                style: textStyle,
              ),
            if (!state.layersEnabled)
              const Text('|  Layers disabled', style: textStyle),
            if (state.layersEnabled &&
                !state.layerFilesLoading &&
                state.layerPlayersPool.globalLayers.isNotEmpty)
              ...state.layerPlayersPool.globalLayers.map(
                (Layer layer) => Text(
                  '${layer.layerName}:${layer.layerVolume.toStringAsFixed(2)}',
                  style: textStyle,
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.white.withValues(alpha: 0.3);
    const alignment = MainAxisAlignment.spaceBetween;

    final n = Provider.of<NavigationProvider>(context);
    final s = Provider.of<ScoreProvider>(context);
    final au = Provider.of<AppUpdateService>(context);
    final ac = Provider.of<AppConnection>(context);

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Version and app status
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: SizedBox(
              width: 230,
              child: Row(
                mainAxisAlignment: alignment,
                children: [
                  StatusBarItem(
                    text: '',
                    value: 'GPhil v.${au.localBuild}',
                  ),
                  StatusBarItem(text: 'App status', value: ac.appState.name),
                  VerticalDivider(thickness: 1, color: dividerColor),
                ],
              ),
            ),
          ),

          // Current score
          Expanded(
            child: Row(
              mainAxisAlignment: alignment,
              children: [
                StatusBarItem(
                  text: 'Current score',
                  value: s.currentScore != null
                      ? '${s.currentScore!.shortTitle} - ${s.currentScore!.composer}'
                      : 'Not selected',
                ),
                VerticalDivider(thickness: 1, color: dividerColor),
              ],
            ),
          ),

          // Current section (Score screen)
          if (n.currentIndex == 2)
            Expanded(
              child: Row(
                mainAxisAlignment: alignment,
                children: [
                  Center(
                    child: StatusBarItem(
                      text: 'Current section',
                      value: s.currentSection.name != ''
                          ? '${s.currentMovement.title} / ${s.currentSection.name}${s.currentSection.updateRequired != null ? '*' : ''}'
                          : 'Not selected',
                    ),
                  ),
                ],
              ),
            ),

          // Tempo status (Performance screen)
          if (n.isPerformanceScreen)
            Selector<PlaylistProvider, String?>(
              selector: (_, provider) => provider.currentMovementKey,
              builder: (context, currentMovementKey, _) {
                if (currentMovementKey == null) return const SizedBox();
                return Expanded(
                  child: Row(
                    mainAxisAlignment: alignment,
                    children: [
                      _buildTempoStatus(context, s),
                      VerticalDivider(thickness: 1, color: dividerColor),
                    ],
                  ),
                );
              },
            ),

          // Player status
          if (n.currentIndex == 1)
            Selector<PlaylistProvider, String?>(
              selector: (_, provider) => provider.currentMovementKey,
              builder: (context, currentMovementKey, _) {
                if (currentMovementKey == null) return const SizedBox();
                return Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildPlayerStatus(context),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

const TextStyle textStyle = TextStyle(
  color: Colors.white,
  fontSize: 12,
  // fontWeight: FontWeight.w100,
);

class StatusBarItem extends StatelessWidget {
  const StatusBarItem({
    super.key,
    required this.text,
    required this.value,
    this.icon,
  });

  final String text;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${text.isNotEmpty ? '$text: ' : ''}$value',
      style: textStyle,
      softWrap: false,
      overflow: TextOverflow.fade,
    );
  }
}
