import 'package:flutter/material.dart';
import 'package:gphil/components/social_button.dart';
import 'package:gphil/theme/constants.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(spacing: 8, children: [
          SocialButton(
              label: 'Support GPhil',
              icon: Icons.paypal,
              url: 'https://www.paypal.com/ncp/payment/3KH4DFTTQMXYJ',
              iconColor: Colors.red.shade900,
              borderColor: highlightColor),
          SocialButton(
              label: 'Report a bug',
              icon: Icons.bug_report,
              url: 'https://discord.gg/DMDvB6NFJu',
              iconColor: Colors.red.shade900,
              borderColor: Colors.red.shade900),
        ]),
      ),
    );
  }
}
