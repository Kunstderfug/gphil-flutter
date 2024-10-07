import 'package:flutter/material.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LayersError extends StatelessWidget {
  const LayersError({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(paddingXl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.onPrimary,
              Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: redColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              p.error,
              style: TextStyle(
                fontSize: fontSizeLg,
                // fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: separatorSm),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.vertical,
              spacing: 6,
              children: [
                const SizedBox(height: separatorXs),
                if (p.tempoIsNotInThoseSections.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    children: [
                      const Text(
                        'Affected sections: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSizeMd,
                        ),
                      ),
                      for (Section section in p.tempoIsNotInThoseSections)
                        Text(
                          section.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeMd,
                          ),
                        ),
                    ],
                  ),
                Text(
                  'Available tempos: ${p.currentSection?.tempoRangeLayers}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: fontSizeMd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: separatorSm),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close, size: 18),
                label: const Text('OK'),
                style: buttonStyle(greenColor, context),
                onPressed: () => p.setError(''),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
