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
import 'package:gphil/providers/loading_state_provider.dart';
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
    debugPrint('PerformanceScreen rebuild');

    return Selector3<LoadingStateProvider, PlaylistProvider, NavigationProvider,
        PerformanceState>(
      selector: (_, loadingState, playlistProvider, navigationProvider) =>
          PerformanceState(
        isLoading: loadingState.isLoading,
        isDownloading: loadingState.isDownloading,
        filesLoaded: loadingState.filesLoaded,
        filesDownloaded: loadingState.filesDownloaded,
        isTempoInAllRanges: loadingState.isTempoInAllRanges,
        error: loadingState.error,
        playlist: playlistProvider.playlist,
      ),
      builder: (context, state, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!state.isTempoInAllRanges &&
              state.error.isNotEmpty &&
              Navigator.canPop(context) == false) {
            _showLayersErrorDialog(context);
          }
        });

        Widget layout = LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth >= 900) {
              return const Stack(
                children: [
                  SingleChildScrollView(child: MainArea()),
                ],
              );
            } else {
              return const TabletBody();
            }
          },
        );

        if (state.playlist.isEmpty && !state.isLoading) {
          return const PlaylistIsEmpty();
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: state.playlist.isEmpty && !state.isLoading
              ? const PlaylistIsEmpty()
              : state.isDownloading || state.isLoading
                  ? LoadingContent(state: state)
                  : layout,
        );
      },
    );
  }
}

class PerformanceState {
  final bool isLoading;
  final bool isDownloading;
  final int filesLoaded;
  final int filesDownloaded;
  final bool isTempoInAllRanges;
  final String error;
  final List playlist;

  const PerformanceState({
    required this.isLoading,
    required this.isDownloading,
    required this.filesLoaded,
    required this.filesDownloaded,
    required this.isTempoInAllRanges,
    required this.error,
    required this.playlist,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformanceState &&
          isLoading == other.isLoading &&
          isDownloading == other.isDownloading &&
          filesLoaded == other.filesLoaded &&
          filesDownloaded == other.filesDownloaded &&
          isTempoInAllRanges == other.isTempoInAllRanges &&
          error == other.error &&
          listEquals(playlist, other.playlist);

  @override
  int get hashCode => Object.hash(
        isLoading,
        isDownloading,
        filesLoaded,
        filesDownloaded,
        isTempoInAllRanges,
        error,
        Object.hashAll(playlist),
      );
}

class LoadingContent extends StatelessWidget {
  final PerformanceState state;

  const LoadingContent({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final p = context.read<PlaylistProvider>();
    final n = context.read<NavigationProvider>();

    return Column(
      children: [
        LoadingFiles(
          filesLoaded: state.filesLoaded,
          filesLength: state.playlist.length,
        ),
        const SizedBox(height: separatorXs),
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
        if (kDebugMode && state.isLoading) DebugInfo(p: p)
      ],
    );
  }
}
