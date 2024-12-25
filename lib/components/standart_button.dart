import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';

class StandartButton extends StatelessWidget {
  const StandartButton(
      {super.key,
      required this.label,
      this.icon,
      this.iconWidget,
      this.iconColor,
      this.borderColor = highlightColor,
      this.iconAlignment = IconAlignment.start,
      required this.callback});
  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final Color? iconColor;
  final Color borderColor;
  final Function() callback;
  final IconAlignment iconAlignment;

  @override
  Widget build(BuildContext context) {
    Widget? iconDisplay;
    if (icon != null) {
      iconDisplay = Icon(icon);
    } else if (iconWidget != null) {
      iconDisplay = iconWidget;
    }

    return TextButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return borderColor.withValues(alpha: 0.2);
            }
            return null;
          },
        ),
        foregroundColor:
            WidgetStatePropertyAll(Theme.of(context).colorScheme.onSurface),
        minimumSize: const WidgetStatePropertyAll(Size(180, 40)),
        iconColor: WidgetStatePropertyAll(iconColor),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: borderColor,
          ),
        ),
      ),
      onPressed: callback,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconAlignment == IconAlignment.start
            ? [
                if (iconDisplay != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: iconDisplay,
                  ),
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ]
            : [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (iconDisplay != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: iconDisplay,
                  ),
              ],
      ),
    );
  }
}
