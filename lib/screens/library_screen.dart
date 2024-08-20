import 'package:flutter/material.dart';
import 'package:gphil/components/library/library_composer.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  int gridCount(double pixels) {
    return (pixels / 600).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<LibraryProvider, AppConnection>(
        builder: (context, l, ac, child) {
      //LOADING STATE
      Widget loading = Center(
        child: ac.appState == AppState.offline
            ? const SizedBox.shrink()
            : SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('L O A D I N G  L I B R A R Y . . .',
                        style: TextStyles().textXl),
                    const SizedBox(
                      height: separatorMd,
                    ),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
      );

      //BODY
      Widget body = SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: isTablet(context)
            ? MediaQuery.sizeOf(context).height - 156
            : MediaQuery.sizeOf(context).height - 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: Text(
                'W E L C O M E    T O    G P H I L${ac.appState == AppState.offline ? ' (offline)' : ''}',
                style: const TextStyle(fontSize: fontSizeLg),
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height - 230,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount(MediaQuery.sizeOf(context).width),
                  crossAxisSpacing: separatorMd,
                  mainAxisSpacing: separatorLg,
                  childAspectRatio: 4 / 3,
                ),
                itemCount: l.indexedLibrary.composers.length,
                itemBuilder: (context, index) {
                  return LibraryComposer(
                    composerName: l.indexedLibrary.composers[index].name,
                    composerScores: l.indexedLibrary.composers[index].scores,
                  );
                },
              ),
            ),
          ],
        ),
      );
      return AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        firstChild: loading,
        secondChild: body,
        crossFadeState:
            l.isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      );
    });
  }
}
