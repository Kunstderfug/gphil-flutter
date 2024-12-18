import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.label,
    required this.icon,
    required this.url,
    required this.iconColor,
    required this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final String url;

  void callback(String url) async {
    await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160, // Set a fixed width for the button
      child: TextButton(
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
          side: WidgetStatePropertyAll(
            BorderSide(
              color: borderColor,
            ),
          ),
        ),
        onPressed: () => callback(url),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8), // Add some space between icon and text
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
