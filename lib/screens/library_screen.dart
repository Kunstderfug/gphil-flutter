import 'package:flutter/material.dart';
import 'package:gphil/components/library/library_section.dart';
import 'package:gphil/components/library/recent_items.dart';
import 'package:gphil/components/library/recently_updated_items.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

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
        height: MediaQuery.sizeOf(context).height - 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 60,
              child: Text(
                'W E L C O M E    T O    G P H I L${ac.appState == AppState.offline ? ' (offline)' : ''}',
                style: const TextStyle(fontSize: fontSizeXl),
              ),
            ),
            const SizedBox(height: separatorMd),
            const Text('L I B R A R Y', style: TextStyle(fontSize: fontSizeLg)),
            const SeparatorLine(),
            const SizedBox(height: separatorMd),
            LibrarySection(l: l),
            const SeparatorLine(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: RecentlyUpdatedItems(l: l)),
                Expanded(child: RecentLibraryItems(l: l)),
              ],
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
