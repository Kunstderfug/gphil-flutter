import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gphil/providers/theme_provider.dart';
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //dark mode text
          const Text(
            'Dark Mode',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          CupertinoSwitch(
              activeColor: Theme.of(context).highlightColor,
              value:
                  Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
              onChanged: (value) =>
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme()),
        ],
      ),
    );
  }
}
