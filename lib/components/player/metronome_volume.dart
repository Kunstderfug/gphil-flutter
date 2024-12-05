import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

    String assetName() {
      return p.metronomeMuted
          ? 'assets/images/metronome_muted.svg'
          : 'assets/images/metronome_active.svg';
    }

    return SizedBox(
      width: 334,
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox.square(
            dimension: 40,
            child: IconButton(
              padding: EdgeInsets.zero, // Remove padding
              constraints: BoxConstraints(), // Remove default constraints
              tooltip: p.metronomeMuted
                  ? "Enable metronome sound"
                  : "Mute metronome",
              icon: SvgPicture.asset(
                assetName(),
                colorFilter: ColorFilter.mode(
                    p.metronomeMuted
                        ? Colors.white.withOpacity(0.3)
                        : p.setColor(),
                    BlendMode.srcIn),
                semanticsLabel: 'Metronome Icon',
              ),
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
            width: 250,
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
                    ? Colors.white.withOpacity(0.2)
                    : p.setColor(),
                thumbStrokeWidth: 1,
                // tooltipBackgroundColor: highlightColor,
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
                  stepSize: 0.1,
                  showTicks: true,
                  showLabels: true,
                  minorTicksPerInterval: 4,
                  activeColor: p.metronomeMuted
                      ? Colors.white.withOpacity(0.2)
                      : p.setColor(),
                  inactiveColor: p.metronomeMuted
                      ? Colors.white.withOpacity(0.1)
                      : p.setInactiveColor(),
                  enableTooltip: true,
                  value: metronomeVolume,
                  onChanged: (value) => p.setMetronomeVolume(value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
