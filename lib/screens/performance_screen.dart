import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/debug_info.dart';
import 'package:gphil/components/performance/floating_info.dart';
import 'package:gphil/components/performance/layers_error.dart';
import 'package:gphil/components/performance/main_area.dart';
import 'package:gphil/components/performance/mixer_info.dart';
import 'package:gphil/components/performance/playlist_empty.dart';
import 'package:gphil/components/standart_button.dart';
import 'package:gphil/components/tablet_body.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final n = Provider.of<NavigationProvider>(context);

    Widget layout = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 900) {
          return SingleChildScrollView(
            child: Stack(
              children: [
                MainArea(),
                if (kDebugMode)
                  FloatingWindow(
                    label: 'Mixer',
                    child: MixerInfo(p: p),
                  ),
                if (p.layersEnabled &&
                    !p.isTempoInAllRanges &&
                    p.error.isNotEmpty)
                  Positioned(
                    bottom: 200,
                    right: 50,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width / 2,
                      // height: 300,
                      child: const LayersError(),
                    ),
                  )
              ],
            ),
          );
        } else {
          return TabletBody();
        }
      },
    );

    if (p.playlist.isEmpty && !p.isLoading) {
      return const PlaylistIsEmpty();
    } else {
      Widget firstChild() {
        if (p.filesDownloading) {
          return Column(
            children: [
              LoadingFiles(
                filesLoaded: p.filesDownloaded,
                filesLength: p.playlist.length,
              ),
              SizedBox(height: separatorXs),
              StandartButton(
                iconColor: redColor,
                borderColor: redColor,
                icon: Icons.cancel,
                label: 'Cancel',
                callback: () {
                  p.filesDownloading = false;
                  n.setScoreScreen();
                },
              ),
            ],
          );
        }
        if (p.isLoading) {
          return Column(
            children: [
              LoadingFiles(
                filesLoaded: p.filesLoaded,
                filesLength: p.playlist.length,
              ),
              SizedBox(height: separatorXs),
              StandartButton(
                iconColor: redColor,
                borderColor: redColor,
                icon: Icons.cancel,
                label: 'Cancel',
                callback: () {
                  p.filesDownloading = false;
                  n.setScoreScreen();
                },
              ),
              if (kDebugMode) DebugInfo(p: p)
            ],
          );
        }
        return SizedBox();
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: p.playlist.isEmpty && !p.isLoading
            ? const PlaylistIsEmpty()
            : p.filesDownloading || p.isLoading
                ? firstChild()
                : layout,
      );
    }
  }
}
