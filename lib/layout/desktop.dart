import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gphil/components/library/library_search.dart';
import 'package:gphil/components/performance/sidebar.dart';
import 'package:gphil/components/score/score_links.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/layout/drawer.dart';
import 'package:gphil/layout/navigation.dart';
import 'package:gphil/layout/status_bar.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/opacity_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  Widget _buildScoreLinks(ScoreProvider s) {
    final double iconSize = 20;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (s.currentScore?.pianoScoreUrl != null)
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: const Icon(
                Icons.piano_outlined,
              ),
              iconSize: iconSize,
              tooltip: 'Download Piano Score',
              color: Colors.white,
              onPressed: () =>
                  launchUrl(Uri.parse(s.currentScore!.pianoScoreUrl!)),
            ),
          if (s.currentScore?.fullScoreUrl != null)
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: const Icon(
                Icons.library_music_outlined,
              ),
              iconSize: iconSize,
              tooltip: 'Download Full Score',
              color: Colors.white,
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
          // color: highlightColor,
          onPressed: () => launchUrl(
              Uri.parse('https://www.paypal.com/ncp/payment/3KH4DFTTQMXYJ')),
        ),
        IconButton(
          hoverColor: redColor,
          icon: const Icon(
            Icons.bug_report,
          ),
          tooltip: 'Report a bug',
          // color: redColor,
          onPressed: () =>
              launchUrl(Uri.parse('https://discord.gg/DMDvB6NFJu')),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);
    final s = Provider.of<ScoreProvider>(context);
    final l = Provider.of<LibraryProvider>(context);
    final t = Provider.of<ThemeProvider>(context);

    return Shortcuts(
      shortcuts: {
        SingleActivator(LogicalKeyboardKey.keyF): const SearchIntent(),
      },
      child: Actions(
        actions: {
          SearchIntent: CallbackAction<SearchIntent>(
            onInvoke: (SearchIntent intent) {
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => LibrarySearch(
                  l: l,
                  closeParentDialog: true,
                  isGlobalSearch: true,
                ),
              );
              return null;
            },
          ),
        },
        child: Focus(
          // autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: !n.isScoreScreen
                ? AppBar(
                    backgroundColor: n.isLibraryScreen
                        ? AppColors().backroundColor(context)
                        : p.performanceMode && p.playlist.isNotEmpty
                            ? p.setColor()
                            : AppColors().backroundColor(context),
                    leading: n.isPerformanceScreen
                        ? _buildScoreLinks(s)
                        : null, // Add this
                    leadingWidth: n.isPerformanceScreen ? 100 : 56, // Add this
                    title: Text(
                        n.isLibraryScreen
                            ? n.navigationScreens[n.currentIndex].title
                            : p.performanceMode && p.playlist.isNotEmpty
                                ? 'P E R F O R M A N C E  M O D E'
                                : n.navigationScreens[n.currentIndex].title,
                        style: Theme.of(context).textTheme.titleMedium),
                    toolbarHeight: appBarSizeDesktop,
                    actions:
                        n.isPerformanceScreen ? [_buildSocialIcons()] : null,
                  )
                : AppBar(
                    title: Padding(
                      padding: const EdgeInsets.only(
                          left: paddingMd, right: paddingMd),
                      child: Stack(
                        fit: StackFit.passthrough,
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.currentScore?.composer.toUpperCase() ?? '',
                                  style: const TextStyle(
                                    fontSize: fontSizeMd,
                                    letterSpacing: 2,
                                    wordSpacing: 4,
                                  )),
                              Text(
                                  '${s.currentScore?.shortTitle.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: fontSizeMd,
                                    letterSpacing: 2,
                                    wordSpacing: 4,
                                  )),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ScoreLinks(
                                  pianoScoreUrl: s.currentScore?.pianoScoreUrl,
                                  fullScoreUrl: s.currentScore?.fullScoreUrl),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // actions: [_buildSocialIcons()],
                    toolbarHeight: appBarSizeDesktop,
                  ),
            body: Stack(children: [
              t.isDarkMode
                  ? Image.asset('assets/images/bg-dark-desktop.png',
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height,
                      fit: BoxFit.fill)
                  : Image.asset('assets/images/bg-light-desktop.png',
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height,
                      fit: BoxFit.fill),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  !n.isPerformanceScreen
                      ? const MyDrawer(child: Navigation())
                      : MyDrawer(
                          child: ChangeNotifierProvider(
                            create: (_) => OpacityProvider(),
                            lazy: false,
                            child: p.playlist.isNotEmpty
                                ? PerformanceSidebar()
                                : const MyDrawer(child: Navigation()),
                          ),
                        ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width - 240,
                    height: MediaQuery.sizeOf(context).height,
                    child: n.isHelpScreen // Add this condition
                        ? n.navigationScreens[n.currentIndex].screen
                        : SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                                horizontal: paddingXl, vertical: paddingSm),
                            child: n.navigationScreens[n.currentIndex].screen,
                          ),
                  ),
                ],
              ),
            ]),
            bottomNavigationBar: ChangeNotifierProvider(
                create: (_) => PersistentDataController(),
                lazy: false,
                child: const StatusBar()),
            floatingActionButton: n.isLibraryScreen
                ? FloatingActionButton(
                    backgroundColor: highlightColor.withValues(alpha: 0.7),
                    onPressed: l.getLibrary,
                    tooltip: 'Refresh Library',
                    child: !l.isLoading
                        ? const Icon(Icons.refresh,
                            size: 32,
                            color: Colors.white,
                            semanticLabel: 'Refresh library')
                        : const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class SearchIntent extends Intent {
  const SearchIntent();
}
