import 'package:flutter/material.dart';
import 'package:gphil/components/player/progress_bar.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SeparatorAndProgressBar extends StatelessWidget {
  final double separatorWidth;
  final double height;
  const SeparatorAndProgressBar(
      {super.key, required this.separatorWidth, required this.height});

  @override
  Widget build(BuildContext context) {
    const double barWidth = 4;
    const double barOffset = 18;
    const double barHeight = 24;
    final p = Provider.of<PlaylistProvider>(context);

    final progressBarAndGuard = LayoutBuilder(builder: (context, constraints) {
      //continie bar guard
      Widget continueGuardBar = Positioned(
        left: constraints.maxWidth / 100 * p.guardPosition - barOffset,
        child: Container(
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            color: redColor,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );

      return Stack(alignment: Alignment.center, children: [
        const ProgressBar(),
        p.currentSection?.autoContinueMarker != null &&
                p.currentSection?.autoContinue != false
            ? Positioned(
                left: constraints.maxWidth /
                        100 *
                        p.adjustedAutoContinuePosition -
                    barOffset,
                child: Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: p.currentSection!.autoContinue! == true
                        ? greenColor
                        : Colors.grey.shade700,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              )
            : continueGuardBar
      ]);
    });

    return SizedBox(
      height: height,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        //HORIZONTALSEPARATOR LINE
        Expanded(
          child: const SeparatorLine(),
        ),

        //Separator
        SizedBox(
          width: separatorWidth,
        ),

        //PROGRESS BAR
        Expanded(
          child: RepaintBoundary(child: progressBarAndGuard),
        )
      ]),
    );
  }
}
