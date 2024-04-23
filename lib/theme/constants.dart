import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:provider/provider.dart';

const iconSize = 24.0;
const separatorXs = 28.0;
const separatorSm = 40.0;
const separatorMd = 52.0;
const separatorLg = 64.0;
const separatorThickness = 2.0;

class ElevatedButtonStyles {
  final buttonLarge = ButtonStyle(
    textStyle: MaterialStatePropertyAll(TextStyles().textLargeBold),
    elevation: const MaterialStatePropertyAll(0),
    padding: const MaterialStatePropertyAll(
      EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 24.0,
      ),
    ),
    shape: MaterialStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRad().bRadiusLg,
      ),
    ),
  );

  final buttonMedium = ButtonStyle(
    textStyle: MaterialStatePropertyAll(TextStyles().textMediumBold),
    elevation: const MaterialStatePropertyAll(0),
    padding: const MaterialStatePropertyAll(
      EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
    ),
    shape: MaterialStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRad().bRadiusMd,
      ),
    ),
  );
}

class BorderRad {
  final bRadiusXs = BorderRadius.circular(8.0);
  final bRadiusSm = BorderRadius.circular(12.0);
  final bRadiusMd = BorderRadius.circular(16.0);
  final bRadiusLg = BorderRadius.circular(24.0);
  final bRadiusXl = BorderRadius.circular(32.0);
  final bRadiusFull = BorderRadius.circular(999.0);
}

class TextStyles {
  final textLargeBold = const TextStyle(
    fontSize: 30.0,
    fontWeight: FontWeight.bold,
  );

  final textLarge = const TextStyle(
    fontSize: 30.0,
  );

  final textMediumBold = const TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.bold,
  );

  final textMedium = const TextStyle(
    fontSize: 22.0,
  );

  final textSmallBold = const TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );

  final textSmall = const TextStyle(
    fontSize: 16.0,
  );

  final textXSmall = const TextStyle(
    fontSize: 12.0,
  );

  final textXSmallBold = const TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
  );
}

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
