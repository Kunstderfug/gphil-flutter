import 'package:flutter/material.dart';
import 'package:gphil/layout/navigation.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      backgroundColor: Theme.of(context).colorScheme.background,
      child: const Navigation(),
    );
  }
}