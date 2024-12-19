import 'package:flutter/material.dart';
import 'package:gphil/components/social_button.dart';
import 'package:gphil/theme/constants.dart';

List<Widget> socialButtons = [
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
];
