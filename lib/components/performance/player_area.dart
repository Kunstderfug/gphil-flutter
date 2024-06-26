import 'package:flutter/material.dart';
import 'package:gphil/components/player/player_control.dart';
import 'package:gphil/components/player/playlist_control.dart';
import 'package:gphil/components/player/progress_bar.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

const double barWidth = 4;
const double barOffset = 18;

class PlayerArea extends StatelessWidget {
  const PlayerArea({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RepaintBoundary(
            child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 720,
                ),
                child: const PlaylistControl())),
        RepaintBoundary(
            child: Container(
          constraints: const BoxConstraints(
            maxWidth: 720,
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            //continie bar guard
            Widget continueGuardBar = Positioned(
              left: constraints.maxWidth / 100 * p.guardPosition - barOffset,
              child: Container(
                width: barWidth,
                height: 48,
                decoration: BoxDecoration(
                  color: redColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
              ),
            );

            return Stack(children: [
              const ProgressBar(),
              p.currentSection?.autoContinueMarker != null &&
                      p.currentSection?.autoContinue != null
                  ? Positioned(
                      left: constraints.maxWidth /
                              100 *
                              p.adjustedAutoContinuePosition -
                          barOffset,
                      child: Container(
                        width: barWidth,
                        height: 48,
                        decoration: BoxDecoration(
                          color: p.currentSection!.autoContinue! == true
                              ? greenColor
                              : Colors.grey.shade700,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    )
                  : continueGuardBar
            ]);
          }),
        )),
        const SizedBox(
          height: 8,
        ),
        const SizedBox(width: 600, child: PlayerControl()),
      ],
    );
  }
}
