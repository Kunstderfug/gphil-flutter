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

    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 180,
            child: SfSliderTheme(
              data: SfSliderThemeData(
                thumbColor: highlightColor,
                activeTrackColor: p.setColor(),
                inactiveTrackColor: p.setInactiveColor(),
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
                  min: 0.0,
                  max: 1.0,
                  interval: 0.5,
                  stepSize: 0.05,
                  showTicks: true,
                  minorTicksPerInterval: 1,
                  activeColor: p.setColor(),
                  inactiveColor: p.setInactiveColor(),
                  enableTooltip: p.layersEnabled,
                  value: layer.layerVolume,
                  onChangeEnd: (value) => p.updateLayersPrefs(),
                  onChanged: (value) => p.layersEnabled
                      ? p.setGlobalLayerVolume(value, layer.layerName)
                      : null),
            ),
          ),
          Text(layer.fullName),
        ],
      ),
    );
  }
}
