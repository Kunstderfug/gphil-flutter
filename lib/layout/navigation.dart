import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/theme/constants.dart';
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
      SizedBox(
        height: 145,
        child: DrawerHeader(
            child: Center(
          child: Image.asset(
            'assets/images/gphil_icon.png',
            width: sizeXl,
            height: sizeXl,
          ),
        )),
      ),

      //NAVIGATION
      ...navigationScreens.getRange(0, 2).map((screen) => NavigationItem(
            title: screen['title'] as String,
            icon: screen['icon'] as IconData,
            index: navigationScreens.indexOf(screen),
          )),

      //DARK MODE
      const Padding(
        padding:
            EdgeInsets.symmetric(horizontal: paddingMd, vertical: paddingXs),
        child: DarkModeSlider(),
      ),
    ]);
  }
}
