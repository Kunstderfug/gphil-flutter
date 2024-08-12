import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class DarkModeSlider extends StatelessWidget {
  const DarkModeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: paddingXs, horizontal: paddingSm),
      margin: const EdgeInsets.all(paddingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //dark mode text
          Text(
            'Dark Mode',
            style: TextStyles().textSm,
          ),
          Transform.scale(
            scale: 0.8,
            child: CupertinoSwitch(
                activeColor: Theme.of(context).highlightColor,
                value: context.read<ThemeProvider>().isDarkMode,
                onChanged: (value) =>
                    context.read<ThemeProvider>().toggleTheme()),
          ),
        ],
      ),
    );
  }
}
