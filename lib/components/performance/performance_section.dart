import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceSection extends StatelessWidget {
  final Section section;
  final void Function() onTap;
  final bool isSelected;
  final Color color;

  const PerformanceSection({
    super.key,
    required this.section,
    required this.onTap,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    double opacity(bool value) => value ? 0.4 : 0;

    return Opacity(
      opacity: section.muted ? 0.3 : 1,
      child: Container(
        height: 32,
        // padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        decoration: BoxDecoration(
            color: section.autoContinue == true
                ? greenColor
                    .withOpacity(isSelected ? 1 : opacity(p.sectionsColorized))
                : redColor
                    .withOpacity(isSelected ? 1 : opacity(p.sectionsColorized)),
            border: isSelected
                ? Border.all(
                    color: Colors.white,
                  )
                : null),
        child: TextButton(
          style: ButtonStyle(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            iconSize: const WidgetStatePropertyAll(iconSizeMd),
            iconColor: WidgetStatePropertyAll(greenColor),
            shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            backgroundColor: WidgetStatePropertyAll(
              isSelected ? p.setColor() : Colors.transparent,
            ),
          ),
          onPressed: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Section name
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isTablet(context)
                        ? section.name.toLowerCase().replaceAll('_', ' ')
                        : section.name.replaceAll('_', ' '),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: fontSizeSm),
                  ),
                ),
              ),
              //Icon for loop
              Expanded(
                flex: 2,
                child: section.looped
                    ? Icon(
                        Icons.loop_sharp,
                        color: !p.performanceMode
                            ? Colors.white
                            : Colors.grey.shade700,
                        size: iconSizeSm,
                      )
                    : SizedBox.shrink(),
              ),
              //Autocontinue icon
              Expanded(
                flex: 2,
                child: section.autoContinue == true
                    ? Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                        size: iconSizeSm,
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
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
