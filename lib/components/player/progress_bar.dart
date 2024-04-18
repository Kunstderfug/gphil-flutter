import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(builder: (context, provider, child) {
      return SliderTheme(
        data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 0,
        )),
        child: Slider(
          min: 0,
          max: provider.totalDuration.inMilliseconds.toDouble(),
          value: provider.currentPosition.inMilliseconds.toDouble(),
          activeColor: Colors.teal.shade300,
          onChanged: (double value) {},
          onChangeEnd: (double value) {
            provider.seek(Duration(milliseconds: value.toInt()));
          },
        ),
      );
    });
  }
}
