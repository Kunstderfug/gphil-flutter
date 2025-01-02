import 'package:flutter/material.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/loading_state_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LayersError extends StatelessWidget {
  const LayersError({
    super.key,
    // required this.p,
  });

  // final PlaylistProvider p;

  @override
  Widget build(BuildContext context) {
    final l = context.watch<LoadingStateProvider>();
    final p = context.read<PlaylistProvider>(); // For non-loading related data
    return Container(
      padding: const EdgeInsets.all(paddingXl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.onPrimary,
            Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: redColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.error,
            style: TextStyle(
              fontSize: 20,
              // fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.8),
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
              icon: Icon(Icons.close, size: 18, color: greenColor),
              label: const Text('OK'),
              style: buttonStyle(greenColor, context),
              onPressed: () {
                p.setError('');
                Navigator.of(context)
                    .pop(); // Add this line to close the dialog
              },
            ),
          ),
        ],
      ),
    );
  }
}
