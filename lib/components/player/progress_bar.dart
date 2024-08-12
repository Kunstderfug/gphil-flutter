import 'package:flutter/material.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, p, child) {
      return SliderTheme(
        data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            // activeTrackColor: setColor(),
            inactiveTrackColor: p.setInactiveColor(),
            trackShape: const RoundedRectSliderTrackShape(),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6,
            )),
        child: Slider(
          min: 0,
          max: p.duration.inMilliseconds.toDouble(),
          value: p.currentPosition.inMilliseconds > p.duration.inMilliseconds
              ? p.duration.inMilliseconds.toDouble()
              : p.currentPosition.inMilliseconds.toDouble(),
          activeColor: p.setColor(),
          onChanged: (double value) {},
          onChangeEnd: (double value) {
            p.seek(Duration(milliseconds: value.toInt()));
          },
        ),
      );
    });
  }
}
