import 'package:flutter/material.dart';
// import 'package:gphil/layout/navigation.dart';

class MyDrawer extends StatelessWidget {
  final Widget child;
  const MyDrawer({super.key, required this.child});

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
      child: child,
    );
  }
}
