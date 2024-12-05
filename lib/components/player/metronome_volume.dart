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
    final double iconSize = 32;
    final double metronomeSize = 50;
    double opacity() => p.metronomeMuted ? 0.2 : 1;

    String assetName() {
      return p.metronomeMuted
          ? 'assets/images/metronome_muted.svg'
          : 'assets/images/metronome_active.svg';
    }

    return SizedBox(
      width: 360,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox.square(
            dimension: metronomeSize,
            child: IconButton(
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
              tooltip: p.metronomeMuted
                  ? "Enable metronome sound"
                  : "Mute metronome",
              icon: SvgPicture.asset(
                assetName(),
                colorFilter: ColorFilter.mode(
                    p.metronomeMuted
                        ? Colors.white.withOpacity(opacity())
                        : p.setColor(),
                    BlendMode.srcIn),
                semanticsLabel: 'Metronome Icon',
              ),
              iconSize: iconSize,
              color: p.metronomeMuted
                  ? Colors.white.withOpacity(opacity())
                  : p.setColor(),
              splashRadius: iconSize,
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
                    ? Colors.white.withOpacity(opacity())
                    : p.setColor(),
                inactiveTrackColor: p.setInactiveColor(),
                activeTrackHeight: 4,
                inactiveTrackHeight: 4,
                thumbRadius: 6,
                thumbStrokeColor: p.metronomeMuted
                    ? Colors.white.withOpacity(opacity())
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
                      ? Colors.white.withOpacity(opacity())
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
          SizedBox.square(
            dimension: metronomeSize,
            child: IconButton(
                padding: EdgeInsets.all(4),
                constraints: BoxConstraints(),
                tooltip: !p.metronomeBellEnabled
                    ? "Enable downbeat bell"
                    : "Disable downbeat bell",
                icon: Icon(
                  p.metronomeBellEnabled
                      ? Icons.notifications_on_outlined
                      : Icons.notifications_off_outlined,
                ),
                iconSize: iconSize,
                color: p.metronomeMuted
                    ? Colors.white.withOpacity(opacity())
                    : p.setColor(),
                splashRadius: iconSize,
                onPressed: p.setMetronomeBellEnabled),
          ),
        ],
      ),
    );
  }
}
