import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class MainVolume extends StatelessWidget {
  const MainVolume({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 300,
          child: SfSlider.vertical(
              interval: 0.5,
              stepSize: 0.05,
              showTicks: true,
              minorTicksPerInterval: 1,
              activeColor: greenColor,
              inactiveColor: greenColor.withOpacity(0.3),
              enableTooltip: true,
              value: p.globalVolume,
              onChanged: (value) => p.setGlobalVolume(value)),
        ),
        const Text('Main volume'),
      ],
    );
  }
}
