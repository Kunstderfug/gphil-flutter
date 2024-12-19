import 'package:flutter/material.dart';
import 'package:gphil/components/social_button.dart';
import 'package:gphil/theme/constants.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 16,
      children: [
        SocialButton(
          label: 'Support GPhil',
          icon: Icons.paypal,
          url: 'https://www.paypal.com/ncp/payment/3KH4DFTTQMXYJ',
          iconColor: highlightColor,
          borderColor: highlightColor,
        ),
        const SizedBox(height: 8),
        SocialButton(
          label: 'Report a bug',
          icon: Icons.bug_report,
          url: 'https://discord.gg/DMDvB6NFJu',
          iconColor: redColor,
          borderColor: redColor,
        ),
      ],
    );
  }
}
