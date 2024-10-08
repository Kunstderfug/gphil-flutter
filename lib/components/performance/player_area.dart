import 'package:flutter/material.dart';
import 'package:gphil/components/player/player_control.dart';

const double barWidth = 4;
const double barOffset = 18;

class PlayerArea extends StatelessWidget {
  const PlayerArea({super.key});

  @override
  Widget build(BuildContext context) {
    const double maxWidth = 720;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RepaintBoundary(
            child: Container(
                constraints: const BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: Column(
                  children: [
                    ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: maxWidth),
                        child: const PlayerControl()),
                  ],
                ))),
      ],
    );
  }
}
