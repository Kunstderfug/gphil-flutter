import 'package:flutter/material.dart';
import 'package:gphil/layout/navigation.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 240,
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.zero,
          bottomRight: Radius.zero,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: const Navigation(),
    );
  }
}
