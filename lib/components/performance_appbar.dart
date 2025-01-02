import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

final iconColor = Colors.white.withValues(alpha: 0.7);

class PlaylistState {
  final bool performanceMode;
  final List playlist;

  PlaylistState(this.performanceMode, this.playlist);
}

class PerformanceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PerformanceAppBar({
    super.key,
    required this.n,
    required this.s,
  });

  final NavigationProvider n;
  final ScoreProvider s;

  @override
  Size get preferredSize => const Size.fromHeight(appBarSizeDesktop);

  @override
  Widget build(BuildContext context) {
    return Selector<PlaylistProvider, PlaylistState>(
      selector: (_, provider) => PlaylistState(
        provider.performanceMode,
        provider.playlist,
      ),
      builder: (context, state, _) {
        return AppBar(
          backgroundColor: n.isLibraryScreen
              ? AppColors().backroundColor(context)
              : state.performanceMode == true &&
                      state.playlist.isNotEmpty == true
                  ? Provider.of<PlaylistProvider>(context, listen: false)
                      .setColor()
                  : AppColors().backroundColor(context),
          leading: n.isPerformanceScreen ? _buildScoreLinks(s) : null,
          leadingWidth: n.isPerformanceScreen ? 100 : 56,
          title: Text(
            n.isLibraryScreen
                ? n.navigationScreens[n.currentIndex].title
                : state.performanceMode == true &&
                        state.playlist.isNotEmpty == true
                    ? 'P E R F O R M A N C E  M O D E'
                    : n.navigationScreens[n.currentIndex].title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          toolbarHeight: appBarSizeDesktop,
          actions: n.isPerformanceScreen ? [_buildSocialIcons()] : null,
        );
      },
    );
  }

  Widget _buildScoreLinks(ScoreProvider s) {
    final double iconSize = 20;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (s.currentScore?.pianoScoreUrl != null)
            IconButton(
              hoverColor: greenColor,
              padding: const EdgeInsets.all(0),
              icon: const Icon(
                Icons.piano_outlined,
              ),
              iconSize: iconSize,
              tooltip: 'Download Piano Score',
              color: iconColor,
              onPressed: () =>
                  launchUrl(Uri.parse(s.currentScore!.pianoScoreUrl!)),
            ),
          if (s.currentScore?.fullScoreUrl != null)
            IconButton(
              hoverColor: greenColor,
              padding: const EdgeInsets.all(0),
              icon: const Icon(
                Icons.library_music_outlined,
              ),
              iconSize: iconSize,
              tooltip: 'Download Full Score',
              color: iconColor,
              onPressed: () =>
                  launchUrl(Uri.parse(s.currentScore!.fullScoreUrl!)),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          hoverColor: highlightColor,
          icon: const Icon(
            Icons.paypal,
          ),
          tooltip: 'Support GPhil',
          color: iconColor,
          onPressed: () => launchUrl(
              Uri.parse('https://www.paypal.com/ncp/payment/3KH4DFTTQMXYJ')),
        ),
        IconButton(
          hoverColor: redColor,
          icon: const Icon(
            Icons.bug_report,
          ),
          tooltip: 'Report a bug',
          color: iconColor,
          onPressed: () =>
              launchUrl(Uri.parse('https://discord.gg/DMDvB6NFJu')),
        ),
      ],
    );
  }
}
