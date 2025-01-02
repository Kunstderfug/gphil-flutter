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
    return SizedBox(
      width: 240,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: sizeMd,
            child: _SliderThemeWrapper(
              child: _buildOpacitySlider(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpacitySlider() {
    return Selector<OpacityProvider, double>(
      selector: (_, provider) => provider.userOpacity,
      builder: (context, opacity, _) {
        final opacityProvider = context.read<OpacityProvider>();
        final playlistProvider = context.read<PlaylistProvider>();

        return SfSlider(
          interval: 0.5,
          stepSize: 0.05,
          showTicks: true,
          minorTicksPerInterval: 1,
          activeColor: playlistProvider.setColor(),
          inactiveColor: playlistProvider.setColor().withValues(alpha: 0.5),
          enableTooltip: false,
          value: opacity,
          onChangeEnd: (dynamic value) =>
              opacityProvider.setOpacity(value as double),
          onChanged: (dynamic value) =>
              opacityProvider.setOpacity(value as double),
        );
      },
    );
  }
}

class _SliderThemeWrapper extends StatelessWidget {
  const _SliderThemeWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistProvider, ({Color color, bool layersEnabled})>(
      selector: (_, provider) => (
        color: provider.setColor(),
        layersEnabled: provider.layersEnabled,
      ),
      builder: (context, data, child) {
        return SfSliderTheme(
          data: SfSliderThemeData(
            thumbColor: highlightColor,
            activeTrackColor: data.color,
            inactiveTrackColor: data.color.withValues(alpha: 0.5),
            activeTrackHeight: 4,
            inactiveTrackHeight: 4,
            thumbRadius: 6,
            thumbStrokeColor: data.layersEnabled ? greenColor : null,
            thumbStrokeWidth: 1,
            tooltipBackgroundColor: highlightColor,
            tooltipTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
      child: child,
    );
  }
}

@override
Widget build(BuildContext context) {
  return Selector<OpacityProvider, double>(
    selector: (_, provider) => provider.userOpacity,
    builder: (context, opacity, _) {
      final opacityProvider = context.read<OpacityProvider>();
      final playlistProvider = context.read<PlaylistProvider>();

      return SfSlider(
        interval: 0.5,
        stepSize: 0.05,
        showTicks: true,
        minorTicksPerInterval: 1,
        activeColor: playlistProvider.setColor(),
        inactiveColor: playlistProvider.setColor().withValues(alpha: 0.5),
        enableTooltip: false,
        value: opacity,
        onChangeEnd: (dynamic value) =>
            opacityProvider.setOpacity(value as double),
        onChanged: (dynamic value) =>
            opacityProvider.setOpacity(value as double),
      );
    },
  );
}
