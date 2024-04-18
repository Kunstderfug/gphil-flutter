import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class NavigationItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final int index;
  const NavigationItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.index});

  @override
  Widget build(BuildContext context) {
    final navigation = Provider.of<NavigationProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 25.0, top: 25),
      child: ListTile(
        title: Text(title),
        leading: Icon(icon),
        onTap: () {
          navigation.setNavigationIndex(index);
        },
      ),
    );
  }
}
