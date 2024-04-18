import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/layout/drawer.dart';
import 'package:provider/provider.dart';

class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = Provider.of<NavigationProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
            navigation.navigationScreens[navigation.currentIndex]['title']
                as String,
            style: Theme.of(context).textTheme.titleLarge),
        // toolbarHeight: 64,
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: navigation.navigationScreens[navigation.currentIndex]['screen']
            as Widget,
      ),
      // bottomNavigationBar: const BottomBar(),
    );
  }
}
