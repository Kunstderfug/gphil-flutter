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
              style: TextStyles().textLg,
            ),
            const SizedBox(height: 16),
            TextButton(
              style: TextButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors().backroundColor(context),
                animationDuration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                ),
              ),
              child: SizedBox(
                width: 140,
                height: 48,
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    const Spacer(),
                    Text('back to Library',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.inversePrimary)),
                  ],
                ),
              ),
              onPressed: () => n.setNavigationIndex(0),
            )
          ],
        ),
      ),
    );
  }
}
