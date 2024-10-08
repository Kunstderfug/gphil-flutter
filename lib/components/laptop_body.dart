import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gphil/components/footer.dart';
import 'package:gphil/components/performance/floating_info.dart';
import 'package:gphil/components/performance/layers_error.dart';
import 'package:gphil/components/performance/main_area.dart';
import 'package:gphil/components/performance/mixer_info.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LaptopBody extends StatelessWidget {
  const LaptopBody({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxLaptopWidth,
          maxHeight: MediaQuery.sizeOf(context).height - 138,
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            AnimatedOpacity(
                opacity: p.isSkippingActive ? 0.3 : 1,
                duration: const Duration(milliseconds: 300),
                child: MainArea()),
            if (kDebugMode) FloatingWindow(child: MixerInfo(p: p)),
            footer,
            //Error message
            if (p.error.isNotEmpty)
              const Positioned(
                top: 600,
                right: 60,
                child: LayersError(),
              ),
          ],
        ));
  }
}
