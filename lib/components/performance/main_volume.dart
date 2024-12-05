import 'package:flutter/material.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
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
          child: SfSliderTheme(
            data: SfSliderThemeData(
              thumbColor: highlightColor,
              activeTrackColor: p.setColor(),
              inactiveTrackColor: p.setInactiveColor(),
              activeTrackHeight: sizeXs,
              inactiveTrackHeight: sizeXs,
              thumbRadius: sizeSm,
              // thumbStrokeColor: p.layersEnabled ? greenColor : null,
              thumbStrokeWidth: 1,
              // tooltipBackgroundColor: highlightColor,
              tooltipTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            child: SfSlider.vertical(
                interval: 0.5,
                stepSize: 0.05,
                showTicks: true,
                minorTicksPerInterval: 1,
                activeColor: p.setColor(),
                inactiveColor: p.setInactiveColor(),
                enableTooltip: true,
                value: p.globalVolume,
                onChanged: (value) => p.setGlobalVolume(value)),
          ),
        ),
        const Text('Main volume'),
      ],
    );
  }
}
