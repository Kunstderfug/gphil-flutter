import 'package:flutter/material.dart';
import 'package:gphil/models/layer_player.dart';
// import 'package:gphil/controllers/persistent_data_controller.dart';
// import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/app_update_service.dart';
// import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.white.withOpacity(0.3);
    const alignment = MainAxisAlignment.spaceBetween;

    final n = Provider.of<NavigationProvider>(context);
    final s = Provider.of<ScoreProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);
    final au = Provider.of<AppUpdateService>(context);
    final ac = Provider.of<AppConnection>(context);
    // final pc = Provider.of<PersistentDataController>(context);

    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 225,
                child: Row(
                  mainAxisAlignment: alignment,
                  children: [
                    StatusBarItem(
                        text: 'GPhil v.${au.localBuild} | App status',
                        value: ac.appState.name),
                    VerticalDivider(
                      thickness: 1,
                      color: dividerColor,
                    ),
                  ],
                )),
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
                child: StatusBarItem(
                    text: 'Current section',
                    value: s.currentSection.name != ''
                        ? '${s.currentMovement.title} / ${s.currentSection.name}${s.currentSection.updateRequired != null ? '*' : ''}'
                        : 'Not selected'),
              ),
            if (n.isPerformanceScreen && p.currentMovementKey != null)
              Expanded(
                child: Row(
                  mainAxisAlignment: alignment,
                  children: [
                    StatusBarItem(
                        text: 'Current section',
                        value: p.currentSection != null
                            ? '${p.currentSection!.name}${p.currentSection?.updateRequired != null ? '*' : ''}, default tempo: ${p.currentSection?.defaultTempo.toString()} ${p.currentSection!.userTempo != null ? '| User tempo: ${p.currentSection!.userTempo}' : ''}'
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
                child: Wrap(spacing: 8, children: [
                  Text('Session: ${p.message}', style: textStyle),
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
          ],
        ),
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
      '$text: $value',
      style: textStyle,
      overflow: TextOverflow.fade,
    );
  }
}
