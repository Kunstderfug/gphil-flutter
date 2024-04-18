import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:provider/provider.dart';

const separatorSm = 40.0;
const separatorMd = 52.0;
const separatorLg = 64.0;
const separatorThickness = 2.0;

final appBar = AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  title: const Text('GPHIL'),
  centerTitle: true,
);

class BackButton extends StatelessWidget {
  const BackButton({super.key});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        final navigator = Provider.of<NavigationProvider>(context);
        navigator.setNavigationIndex(0);
      },
    );
  }
}

class SeparatorLine extends StatelessWidget {
  const SeparatorLine({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return SizedBox(
      height: separatorMd,
      child: Center(
        child: Container(
          height: separatorThickness,
          decoration: BoxDecoration(
            color: theme.themeData.highlightColor,
          ),
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconSize: 24,
      selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
      unselectedItemColor: Theme.of(context).colorScheme.secondary,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
