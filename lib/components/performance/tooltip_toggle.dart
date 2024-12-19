import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';

class TooltipToggle extends StatelessWidget {
  final Widget child;
  final String message;
  const TooltipToggle({super.key, required this.child, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: separatorLg,
      child: Tooltip(
        message: message,
        waitDuration: const Duration(milliseconds: 1000),
        showDuration: const Duration(milliseconds: 3000),
        exitDuration: const Duration(milliseconds: 200),
        enableTapToDismiss: false,
        preferBelow: true,
        enableFeedback: true,
        child: child,
      ),
    );
  }
}
