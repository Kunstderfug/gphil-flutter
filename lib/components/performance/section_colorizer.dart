import 'package:flutter/material.dart';
import 'package:gphil/components/performance/opacity_slider.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/performance/tooltip_toggle.dart';
import 'package:gphil/providers/opacity_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class SectionColorizer extends StatelessWidget {
  const SectionColorizer({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final o = Provider.of<OpacityProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (p.sectionsColorized) OpacitySlider(),
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: TooltipToggle(
            message: 'Colorize sections background according to auto-continue',
            child: AutoSwitch(
              p: p,
              value: p.sectionsColorized,
              onToggle: (value) {
                p.setSectionsColorized(value);
                if (!value) {
                  o.resetOpacity();
                } else {
                  o.getOpacity();
                }
              },
              opacity: 1,
              label: 'Colorize sections',
            ),
          ),
        ),
      ],
    );
  }
}
