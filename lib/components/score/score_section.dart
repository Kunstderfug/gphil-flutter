import 'package:flutter/material.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'dart:math' as math;

import 'package:provider/provider.dart';

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
    final p = Provider.of<PlaylistProvider>(context);
    final n = Provider.of<NavigationProvider>(context);

    return Opacity(
      opacity: section.muted ? 0.3 : 1,
      child: Stack(
        children: [
          TextButton.icon(
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
                isSelected
                    ? Theme.of(context).highlightColor
                    : Colors.transparent,
              ),
              // foregroundColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
          ),
          if (section.looped && n.isPerformanceScreen)
            Positioned(
                left: 0,
                top: 9,
                child: Icon(
                  Icons.loop_sharp,
                  color: !p.performanceMode ? greenColor : Colors.grey.shade700,
                  size: iconSizeXs,
                )),
        ],
      ),
    );
  }
}

class LoopArrowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color borderColor;
  final double borderWidth;

  const LoopArrowButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LoopArrowPainter(
        color: borderColor,
        strokeWidth: borderWidth,
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

class LoopArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  LoopArrowPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();

    // Start from top-left corner
    path.moveTo(size.width * 0.1, size.height * 0.1);

    // Top line
    path.lineTo(size.width * 0.9, size.height * 0.1);

    // Right side
    path.lineTo(size.width * 0.9, size.height * 0.9);

    // Bottom line
    path.lineTo(size.width * 0.1, size.height * 0.9);

    // Left side (partial)
    path.lineTo(size.width * 0.1, size.height * 0.5);

    // Loop arrow
    final centerX = size.width * 0.1;
    final centerY = size.height * 0.3;
    final radius = size.height * 0.2;

    path.addArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      -math.pi / 2,
      math.pi * 1.5,
    );

    // Arrow head
    final arrowSize = size.width * 0.05;
    path.moveTo(centerX - arrowSize, centerY - radius);
    path.lineTo(centerX, centerY - radius - arrowSize);
    path.lineTo(centerX + arrowSize, centerY - radius);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
