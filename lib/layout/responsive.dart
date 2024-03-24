import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget tabletLayout;
  final Widget desktopLayout;

  const ResponsiveLayout(
      {super.key, required this.tabletLayout, required this.desktopLayout});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 1600) {
        return tabletLayout;
      } else {
        return desktopLayout;
      }
    });
  }
}
