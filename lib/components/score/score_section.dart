import 'package:flutter/material.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/theme/constants.dart';

class ScoreSection extends StatelessWidget {
  final Section section;
  final void Function() onTap;
  final bool isSelected;
  const ScoreSection({
    super.key,
    required this.section,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isAutoContinue = section.autoContinue == true;

    return TextButton.icon(
      icon: section.autoContinueMarker != null
          ? Opacity(
              opacity: !isAutoContinue ? 0.3 : 1,
              child: const Icon(Icons.navigate_next))
          : null,
      iconAlignment: IconAlignment.end,
      label: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: paddingSm, horizontal: paddingSm),
        child: Text(
          isTablet(context)
              ? section.name.toLowerCase().replaceAll('_', ' ')
              : section.name.replaceAll('_', ' '),
          style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: fontSizeSm),
        ),
      ),
      onPressed: onTap,
      style: ButtonStyle(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        iconSize: const WidgetStatePropertyAll(iconSizeXs),
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
