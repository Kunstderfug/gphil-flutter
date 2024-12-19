import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';

class LayerToggleSwitch extends StatelessWidget {
  final PlaylistProvider p;
  const LayerToggleSwitch({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    bool layerAvailable() {
      return p.currentSection?.layers != null &&
          p.currentSection!.layers!.isNotEmpty;
    }

    return Opacity(
      opacity: layerAvailable() ? 1.0 : globalDisabledOpacity,
      child: Align(
        alignment: Alignment.topRight,
        child: AutoSwitch(
          p: p,
          onToggle: (value) =>
              layerAvailable() ? p.setLayersEnabled(value) : null,
          value: layerAvailable() ? p.layersEnabled : false,
          label: layerAvailable()
              ? p.layersEnabled
                  ? 'Layers enabled'
                  : 'Layers disabled'
              : 'Layers are not available',
          opacity: p.currentSection?.layers != null ? 1 : 0.4,
        ),
      ),
    );
  }
}
