import 'package:flutter/material.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/providers/playlist_provider.dart';

class LayerToggleSwitch extends StatelessWidget {
  final PlaylistProvider p;
  const LayerToggleSwitch({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: AutoSwitch(
        p: p,
        onToggle: (value) =>
            p.currentSection?.layers != null ? p.setLayersEnabled(value) : null,
        value: p.currentSection?.layers != null ? p.layersEnabled : false,
        label: p.currentSection?.layers != null
            ? p.layersEnabled
                ? 'Layers enabled'
                : 'Layers disabled'
            : 'Layers are not available',
        opacity: p.currentSection?.layers != null ? 1 : 0.4,
      ),
    );
  }
}
