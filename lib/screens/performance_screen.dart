import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/debug_info.dart';
// import 'package:gphil/components/performance/floating_info.dart';
import 'package:gphil/components/performance/layers_error.dart';
import 'package:gphil/components/performance/main_area.dart';
// import 'package:gphil/components/performance/mixer_info.dart';
import 'package:gphil/components/performance/playlist_empty.dart';
import 'package:gphil/components/standart_button.dart';
import 'package:gphil/components/tablet_body.dart';
import 'package:gphil/providers/liading_state_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

void _showLayersErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: 600,
          // height: 400,
          child: LayersError(),
        ),
      );
    },
  );
}

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.watch<LoadingStateProvider>();
    final p = context.read<PlaylistProvider>();
    final n = Provider.of<NavigationProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!l.isTempoInAllRanges &&
          l.error.isNotEmpty &&
          Navigator.canPop(context) == false) {
        _showLayersErrorDialog(context);
      }
    });

    Widget layout = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth >= 900) {
          return Stack(
            children: [
              SingleChildScrollView(child: MainArea()),
              // if (kDebugMode)
              //   FloatingWindow(
              //     label: 'Mixer',
              //     child: MixerInfo(p: p),
              //   ),
            ],
          );
        } else {
          return TabletBody();
        }
      },
    );

    if (p.playlist.isEmpty && !l.isLoading) {
      return const PlaylistIsEmpty();
    } else {
      Widget firstChild() {
        if (l.isDownloading) {
          return Column(
            children: [
              LoadingFiles(
                filesLoaded: l.filesDownloaded,
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
        if (l.isLoading) {
          return Column(
            children: [
              LoadingFiles(
                filesLoaded: l.filesLoaded,
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
        child: p.playlist.isEmpty && !l.isLoading
            ? const PlaylistIsEmpty()
            : l.isDownloading || l.isLoading
                ? firstChild()
                : layout,
      );
    }
  }
}
