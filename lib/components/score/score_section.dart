import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';

class ScoreSection extends StatelessWidget {
  final String name;
  final void Function() onTap;
  final bool isSelected;
  final bool isAutoContinue;
  const ScoreSection(
      {super.key,
      required this.name,
      required this.onTap,
      required this.isSelected,
      required this.isAutoContinue});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: isAutoContinue ? const Icon(Icons.navigate_next) : null,
      iconAlignment: IconAlignment.end,
      label: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: paddingSm, horizontal: paddingMd),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth < 600;
            return Text(
              isTablet
                  ? name.toLowerCase().replaceAll('_', ' ')
                  : name.replaceAll('_', ' '),
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            );
          },
        ),
      ),
      onPressed: onTap,
      style: ButtonStyle(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        iconSize: const WidgetStatePropertyAll(iconSizeSm),
        iconColor: WidgetStatePropertyAll(greenColor),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRad().bRadiusXl,
        )),
        backgroundColor: WidgetStatePropertyAll(
          isSelected ? Theme.of(context).highlightColor : Colors.transparent,
        ),
        // foregroundColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}
