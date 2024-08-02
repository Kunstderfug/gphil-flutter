import 'package:flutter/material.dart';
import 'package:gphil/models/layer_player.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class LayerChannelLevel extends StatelessWidget {
  final Layer layer;
  const LayerChannelLevel({super.key, required this.layer});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Opacity(
          opacity: 1,
          child: SizedBox(
            height: 260,
            width: 100,
            child: SfSliderTheme(
              data: SfSliderThemeData(
                thumbColor: highlightColor,
                activeTrackColor: greenColor,
                inactiveTrackColor: greenColor.withOpacity(0.3),
                activeTrackHeight: 4,
                inactiveTrackHeight: 4,
                thumbRadius: 6,
                thumbStrokeColor: p.layersEnabled ? greenColor : null,
                thumbStrokeWidth: 1,
                tooltipBackgroundColor: p.layersEnabled ? highlightColor : null,
                tooltipTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              child: SfSlider.vertical(
                  interval: 0.5,
                  stepSize: 0.05,
                  showTicks: true,
                  minorTicksPerInterval: 1,
                  activeColor: greenColor,
                  inactiveColor: greenColor.withOpacity(0.3),
                  enableTooltip: p.layersEnabled,
                  value: layer.volume,
                  onChangeEnd: (value) => p.updateLayersPrefs(),
                  onChanged: (value) => p.layersEnabled
                      ? p.setGlobalLayerVolume(value, layer.layerName)
                      : null),
            ),
          ),
        ),
        Text(layer.fullName),
      ],
    );
  }
}
