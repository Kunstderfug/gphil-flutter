import 'package:flutter/material.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/app_update_service.dart';
import 'package:provider/provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.white.withValues(alpha: 0.3);
    const alignment = MainAxisAlignment.spaceBetween;

    final n = Provider.of<NavigationProvider>(context);
    final s = Provider.of<ScoreProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);
    final au = Provider.of<AppUpdateService>(context);
    final ac = Provider.of<AppConnection>(context);

    bool ifTempoChanged() {
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

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    VerticalDivider(
                      thickness: 1,
                      color: dividerColor,
                    ),
                  ],
                )),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: alignment,
              children: [
                StatusBarItem(
                    text: 'Current score',
                    value: s.currentScore != null
                        ? '${s.currentScore!.shortTitle} - ${s.currentScore!.composer}'
                        : 'Not selected'),
                VerticalDivider(
                  thickness: 1,
                  color: dividerColor,
                ),
              ],
            ),
          ),
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
                            : 'Not selected'),
                  ),
                ],
              ),
            ),
          if (n.isPerformanceScreen && p.currentMovementKey != null)
            Expanded(
              child: Row(
                mainAxisAlignment: alignment,
                children: [
                  StatusBarItem(
                      text: '',
                      value: p.currentSection != null && !p.isLoading
                          ? 'Default tempo: ${p.currentSection?.defaultTempo.toString()} ${p.currentSection!.userTempo != null ? '| User tempo: ${p.currentSection!.userTempo}${ifTempoChanged() ? '*' : ''}' : ''}'
                          : 'Not selected'),
                  VerticalDivider(
                    thickness: 1,
                    color: dividerColor,
                  ),
                ],
              ),
            ),
          if (n.currentIndex == 1 && p.currentMovementKey != null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(mainAxisAlignment: alignment, children: [
                    Text(p.message, style: textStyle),
                    if (!p.isLoading)
                      Text(
                          '|  Player volume: ${p.playerVolume.toStringAsFixed(2)}',
                          style: textStyle),
                    if (!p.layersEnabled)
                      const Text('|  Layers disabled', style: textStyle),
                    if (p.layersEnabled &&
                        !p.layerFilesLoading &&
                        p.layerPlayersPool.globalLayers.isNotEmpty)
                      ...p.layerPlayersPool.globalLayers.map((Layer layer) => Text(
                          '${layer.layerName}:${layer.layerVolume.toStringAsFixed(2)}',
                          style: textStyle)),
                  ]),
                ),
              ),
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
