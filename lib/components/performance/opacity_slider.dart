import 'package:flutter/material.dart';
import 'package:gphil/providers/opacity_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class OpacitySlider extends StatelessWidget {
  const OpacitySlider({super.key});

  @override
  Widget build(BuildContext context) {
    final o = Provider.of<OpacityProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);
    return SizedBox(
      // height: 50,
      width: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: sizeMd,
            child: SfSliderTheme(
              data: SfSliderThemeData(
                thumbColor: highlightColor,
                activeTrackColor: p.setColor(),
                inactiveTrackColor: p.setColor().withOpacity(0.5),
                activeTrackHeight: 4,
                inactiveTrackHeight: 4,
                thumbRadius: 6,
                thumbStrokeColor: p.layersEnabled ? greenColor : null,
                thumbStrokeWidth: 1,
                tooltipBackgroundColor: highlightColor,
                tooltipTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              child: SfSlider(
                  interval: 0.5,
                  stepSize: 0.05,
                  showTicks: true,
                  minorTicksPerInterval: 1,
                  activeColor: p.setColor(),
                  inactiveColor: p.setColor().withOpacity(0.5),
                  enableTooltip: false,
                  value: o.userOpacity,
                  onChangeEnd: (value) => o.setOpacity(value),
                  onChanged: (value) => o.setOpacity(value)),
            ),
          ),
        ],
      ),
    );
  }
}
