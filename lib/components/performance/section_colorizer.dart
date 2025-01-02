import 'package:flutter/material.dart';
import 'package:gphil/components/performance/opacity_slider.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/performance/tooltip_toggle.dart';
import 'package:gphil/providers/opacity_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class ColorizerState {
  final bool sectionsColorized;

  const ColorizerState({
    required this.sectionsColorized,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorizerState && sectionsColorized == other.sectionsColorized;

  @override
  int get hashCode => sectionsColorized.hashCode;
}

class SectionColorizer extends StatelessWidget {
  const SectionColorizer({super.key});

  Widget _buildColorizerSwitch(
    BuildContext context,
    bool sectionsColorized,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 14.0),
      child: TooltipToggle(
        message: 'Colorize sections background according to auto-continue',
        child: AutoSwitch(
          value: sectionsColorized,
          onToggle: (value) {
            final playlistProvider =
                Provider.of<PlaylistProvider>(context, listen: false);
            final opacityProvider =
                Provider.of<OpacityProvider>(context, listen: false);

            playlistProvider.setSectionsColorized(value);
            if (!value) {
              opacityProvider.resetOpacity();
            } else {
              opacityProvider.getOpacity();
            }
          },
          opacity: 1,
          label: 'Colorize sections',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistProvider, ColorizerState>(
      selector: (_, provider) => ColorizerState(
        sectionsColorized: provider.sectionsColorized,
      ),
      builder: (context, state, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (state.sectionsColorized) const OpacitySlider(),
            _buildColorizerSwitch(context, state.sectionsColorized),
          ],
        );
      },
    );
  }
}
