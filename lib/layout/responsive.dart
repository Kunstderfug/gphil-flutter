import 'package:flutter/material.dart';
import 'package:gphil/components/footer.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget tabletLayout;
  final Widget desktopLayout;

  const ResponsiveLayout(
      {super.key, required this.tabletLayout, required this.desktopLayout});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final Widget footer = Positioned(
      bottom: 64,
      right: 48,
      child: Footer(),
    );

    return LayoutBuilder(builder: (context, constraints) {
      if (isTablet(context)) {
        return Stack(
          children: [tabletLayout, if (n.isPerformanceScreen) footer],
        );
      } else {
        return Stack(
          children: [desktopLayout, if (n.isPerformanceScreen) footer],
        );
      }
    });
  }
}
