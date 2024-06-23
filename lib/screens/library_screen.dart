import 'package:flutter/material.dart';
import 'package:gphil/components/library/library_composer.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  int gridCount(double pixels) {
    return (pixels / 700).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(builder: (context, provider, child) {
      Widget loading = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('L O A D I N G  L I B R A R Y . . .',
                style: TextStyles().textXl),
            const SizedBox(
              height: 18,
            ),
            const CircularProgressIndicator(),
          ],
        ),
      );

      Widget body = SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: isTablet(context)
            ? MediaQuery.sizeOf(context).height - 156
            : MediaQuery.sizeOf(context).height - 160,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount(MediaQuery.sizeOf(context).width),
            crossAxisSpacing: 24,
            mainAxisSpacing: 48,
            childAspectRatio: 4 / 3,
          ),
          itemCount: provider.indexedLibrary.composers.length,
          itemBuilder: (context, index) {
            return LibraryComposer(
              composerName: provider.indexedLibrary.composers[index].name,
              composerScores: provider.indexedLibrary.composers[index].scores,
            );
          },
        ),
      );
      return AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        firstChild: SizedBox(
          child: loading,
        ),
        secondChild: body,
        crossFadeState: provider.isLoading
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
      );
    });
  }
}
