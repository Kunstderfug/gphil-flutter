import 'package:flutter/material.dart';
import 'package:gphil/components/performance/sidebar.dart';
import 'package:gphil/layout/navigation.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/layout/drawer.dart';
import 'package:gphil/providers/opacity_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
// import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class TabletLayout extends StatefulWidget {
  const TabletLayout({super.key});

  @override
  State<TabletLayout> createState() => _TabletLayoutState();
}

class _TabletLayoutState extends State<TabletLayout>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final t = Provider.of<ThemeProvider>(context);
    // final s = Provider.of<ScoreProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);

    // Convert navigation index to tab index
    int tabIndex = n.currentIndex;
    if (n.currentIndex == 3) {
      // If it's the Help screen
      tabIndex = 2;
    } else if (n.currentIndex > 1) {
      // If it's not Library or Performance
      tabIndex = 0; // Default to first tab
    }

    // Update tab controller when navigation changes
    if (_tabController.index != tabIndex) {
      _tabController.animateTo(tabIndex);
    }

    final double availableHeight =
        MediaQuery.of(context).size.height - appBarSizeDesktop;

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: !n.isPerformanceScreen
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarSizeDesktop),
        child: AppBar(
          elevation: 0,
          backgroundColor:
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          title: TabBar(
            controller: _tabController,
            onTap: (index) {
              int navigationIndex = index;
              if (index == 2) {
                navigationIndex = 3;
              }
              n.setNavigationIndex(navigationIndex);
            },
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(n.navigationScreens[0].title),
                    SizedBox(width: 8),
                    Icon(n.navigationScreens[0].icon),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(n.navigationScreens[1].title),
                    SizedBox(width: 8),
                    Icon(n.navigationScreens[1].icon),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(n.navigationScreens[3].title),
                    SizedBox(width: 8),
                    Icon(n.navigationScreens[3].icon),
                  ],
                ),
              ),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
            indicator: BoxDecoration(
              color: highlightColor,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.symmetric(horizontal: 16),
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) {
                  return highlightColor.withValues(alpha: 0.1);
                }
                return null;
              },
            ),
          ),
          // Remove the bottom property since we moved TabBar to title
          titleSpacing: 0, // Removes default title padding
        ),
      ),
      body: Stack(
        children: [
          // Background image
          t.isDarkMode
              ? Image.asset(
                  'assets/images/bg-dark-tablet.png',
                  width: MediaQuery.sizeOf(context).width,
                  height: availableHeight,
                  fit: BoxFit.cover,
                )
              : Image.asset(
                  'assets/images/bg-light-tablet.png',
                  width: MediaQuery.sizeOf(context).width,
                  height: availableHeight,
                  fit: BoxFit.cover,
                ),
          // Content
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: availableHeight,
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              child: n.navigationScreens[n.currentIndex].screen,
            ),
          ),
        ],
      ),
    );
  }
}
