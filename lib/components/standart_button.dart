import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';

class StandartButton extends StatelessWidget {
  const StandartButton(
      {super.key,
      required this.label,
      this.icon,
      this.iconColor,
      this.borderColor = highlightColor,
      required this.callback});
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final Color borderColor;
  final Function() callback;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      iconAlignment: IconAlignment.start,
      icon: Icon(
        icon,
      ),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return borderColor
                  .withOpacity(0.2); // Set the background color on hover
            }
            return null; // Use the default button background color
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
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
