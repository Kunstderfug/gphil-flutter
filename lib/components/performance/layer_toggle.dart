import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LayerToggleState {
  final bool layersEnabled;
  final Section? currentSection;

  const LayerToggleState(this.layersEnabled, this.currentSection);

  bool get layerAvailable =>
      currentSection?.layers != null && currentSection!.layers!.isNotEmpty;
}

class LayerToggleSwitch extends StatelessWidget {
  const LayerToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistProvider, LayerToggleState>(
      selector: (_, provider) => LayerToggleState(
        provider.layersEnabled,
        provider.currentSection,
      ),
      builder: (context, state, _) {
        return Opacity(
          opacity: state.layerAvailable ? 1.0 : globalDisabledOpacity,
          child: Align(
            alignment: Alignment.topRight,
            child: AutoSwitch(
              onToggle: (value) => state.layerAvailable
                  ? Provider.of<PlaylistProvider>(context, listen: false)
                      .setLayersEnabled(value)
                  : null,
              value: state.layerAvailable ? state.layersEnabled : false,
              label: state.layerAvailable
                  ? state.layersEnabled
                      ? 'Layers enabled'
                      : 'Layers disabled'
                  : 'Layers are not available',
              opacity: state.currentSection?.layers != null ? 1 : 0.4,
            ),
          ),
        );
      },
    );
  }
}
