import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';

class StandardButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;

  const StandardButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : null,
      label: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: paddingLg, vertical: paddingSm),
        child: Text(label),
      ),
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(highlightColor),
        foregroundColor: WidgetStatePropertyAll(Colors.white70),
      ),
    );
  }
}
