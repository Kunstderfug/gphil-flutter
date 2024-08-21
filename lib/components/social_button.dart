import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialButton extends StatelessWidget {
  const SocialButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.url,
      required this.iconColor,
      required this.borderColor});
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
      onPressed: () => callback(url),
      label: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
