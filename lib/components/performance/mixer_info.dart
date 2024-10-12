import 'package:flutter/material.dart';
import 'package:gphil/models/layer_player.dart';
// import 'package:gphil/models/layer_player.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
// import 'package:gphil/services/app_state.dart';

class MixerInfo extends StatelessWidget {
  final PlaylistProvider p;
  const MixerInfo({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    // final LayerPlayerPool? currentPool = p.currentLayerPlayerPool;
    // final pools = p.layerPlayersPool.globalPools;

    //Loaded files
    List<Widget> info = [
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Files loaded: ${p.currentlyLoadedFiles.length}'),
            SeparatorLine(height: separatorSm),
            for (String file in p.currentlyLoadedFiles) Text(file),
          ],
        ),
      ),

      //Players volume ans section info
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Players Volume'),
          SeparatorLine(height: separatorSm),
          if (p.isPlaying)
            Text('Main player volume: ${p.player.getVolume(p.activeHandle!)}'),
          if (p.currentLayerPlayerPool != null && p.isPlaying)
            Text(
                'Layers volume: ${p.currentLayerPlayerPool!.layerChannels[0].player!.playerVolume}'),
          Text('is Playing: ${p.isPlaying}'),
          Text('isSection looped: ${p.currentSection?.muted} '),
          Text('Loop Stropped: ${p.loopStropped}'),
          Text(
              'Current Section: ${p.currentSection?.name ?? ''}, ${p.currentSectionKey}'),
          Text('autoContinueMarker: ${p.autoContinueMarker}'),
          Text('isLoopingActive: ${p.isLoopingActive} '),
          Text(
              'muted == true & !perfM: ${p.currentSection?.muted == true && !p.performanceMode}')
        ],
      ),

      //Pool tempos
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Layers Pool tempos'),
            SeparatorLine(height: separatorSm),
            if (p.currentLayerPlayerPool != null)
              for (LayerPlayerPool pool in p.layerPlayersPool.globalPools)
                Text('Pool tempo: ${pool.tempo}'),
          ],
        ),
      ),

      //Current Pool
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Pool'),
          SeparatorLine(height: separatorSm),
          Text('${p.currentLayerPlayerPool?.tempo ?? 'No current pool'}'),
          for (LayerPlayer player
              in p.currentLayerPlayerPool?.orderedPlayers ?? [])
            Text('Source: ${player.activeHandle ?? 'No handle'}'),
        ],
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth,
            minHeight: constraints.maxHeight,
          ),
          child: buildGrid(info, constraints),
        );
      },
    );
  }

  Widget buildGrid(List<Widget> info, BoxConstraints constraints) {
    return GridView.count(
      crossAxisCount: info.length,
      mainAxisSpacing: sizeMd,
      shrinkWrap: true,
      childAspectRatio:
          (1 / info.length) * constraints.maxWidth / constraints.maxHeight,
      children: info,
    );
  }
}
