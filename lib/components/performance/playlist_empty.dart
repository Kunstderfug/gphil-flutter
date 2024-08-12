import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PlaylistIsEmpty extends StatelessWidget {
  const PlaylistIsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context, listen: false);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height - 160,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Playlist is empty',
              style: TextStyles().textXl,
            ),
            const SizedBox(height: 16),
            const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. Select a score from the library'),
                  SizedBox(height: 16),
                  Text('2. Add movement/movements to the playlist'),
                  SizedBox(height: 16),
                  Text('3. Press Start Session'),
                  SizedBox(height: 16),
                ]),
            const SizedBox(width: 300, child: SeparatorLine()),
            const SizedBox(height: 16),
            TextButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('back to Library'),
              ),
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(highlightColor),
                foregroundColor: WidgetStatePropertyAll(Colors.white70),
              ),
              onPressed: () => n.setNavigationIndex(0),
            )
          ],
        ),
      ),
    );
  }
}
