import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/theme/dark_mode.dart';
import 'package:gphil/layout/navigation_item.dart';
import 'package:provider/provider.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final navigationScreens = navigationProvider.navigationScreens;
    return Column(children: [
      //logo
      DrawerHeader(
          child: Center(
        child: Icon(
          Icons.music_note,
          size: 40,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      )),

      //NAVIGATION
      ...navigationScreens.getRange(0, 2).map((screen) => NavigationItem(
            title: screen['title'] as String,
            icon: screen['icon'] as IconData,
            index: navigationScreens.indexOf(screen),
          )),

      //DARK MODE
      const Padding(
        padding: EdgeInsets.all(25.0),
        child: DarkModeSlider(),
      ),
    ]);
  }
}
