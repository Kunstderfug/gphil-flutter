import 'package:flutter/material.dart';
// import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class MetronomeVolume extends StatelessWidget {
  final double metronomeVolume;
  // final Section section;
  const MetronomeVolume({
    super.key,
    // required this.section,
    required this.metronomeVolume,
  });

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    return SizedBox(
      width: 300,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox.square(
            dimension: 40,
            child: IconButton(
              padding: EdgeInsets.zero, // Remove padding
              constraints: BoxConstraints(), // Remove default constraints
              tooltip: p.metronomeMuted ? "Unmute metronome" : "Mute metronome",
              icon: Image.asset(p.metronomeMuted || metronomeVolume == 0.0
                  ? 'assets/images/metronome-muted.png'
                  : 'assets/images/metronome-active.png'),
              iconSize: 24,
              color: p.metronomeMuted
                  ? Colors.white.withOpacity(0.5)
                  : p.setColor(),
              splashRadius: 8.0,
              onPressed: () {
                p.setMetronomeMuted();
              },
            ),
          ),
          SizedBox(
            // height: 60,
            child: SfSliderTheme(
              data: SfSliderThemeData(
                thumbColor: highlightColor,
                activeTrackColor: p.metronomeMuted
                    ? Colors.white.withOpacity(0.3)
                    : p.setColor(),
                inactiveTrackColor: p.setInactiveColor(),
                activeTrackHeight: 4,
                inactiveTrackHeight: 4,
                thumbRadius: 6,
                thumbStrokeColor: p.metronomeMuted
                    ? Colors.white.withOpacity(0.3)
                    : p.setColor(),
                thumbStrokeWidth: 1,
                tooltipBackgroundColor: highlightColor,
                tooltipTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              child: InkWell(
                onDoubleTap: () => p.resetMetronomeVolume(),
                child: SfSlider(
                  min: 0.0,
                  max: 1.0,
                  interval: 0.5,
                  stepSize: 0.25,
                  showTicks: true,
                  showLabels: true,
                  minorTicksPerInterval: 1,
                  activeColor: p.metronomeMuted
                      ? Colors.white.withOpacity(0.3)
                      : p.setColor(),
                  inactiveColor: p.metronomeMuted
                      ? Colors.white.withOpacity(0.1)
                      : p.setInactiveColor(),
                  enableTooltip: true,
                  value: p.metronomeMuted ? 0.0 : metronomeVolume,
                  onChanged: (value) => p.setMetronomeVolume(value),
                  onChangeEnd: (value) => p.setMetronomeVolume(value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
