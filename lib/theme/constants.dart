import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:provider/provider.dart';

//paddings
const paddingSm = 8.0;
const paddingMd = 16.0;
const paddingLg = 24.0;
const paddingXl = 32.0;

//icon sizes
const iconSizeSm = 24.0;
const iconSizeMd = 32.0;
const iconSizeLg = 48.0;
const iconSizeXl = 64.0;

//separators
const separatorXs = 28.0;
const separatorSm = 40.0;
const separatorMd = 52.0;
const separatorLg = 64.0;
const separatorThickness = 2.0;

//app bar
const appBarSize = 84.0;
const appBarSizeDesktop = 64.0;

//text
const normalLetterSpace = 1.0;
const mediumLetterSpace = 2.0;
const largeLetterSpace = 4.0;
const fontSizeXs = 8.0;
const fontSizeSm = 12.0;
const fontSizeMd = 16.0;
const fontSizeLg = 24.0;
const fontSizeXl = 32.0;
const fontSize2Xl = 48.0;
const fontSize3Xl = 64.0;
const fontSize4Xl = 96.0;

//colors
final greenColor = Colors.green.shade600;
final redColor = Colors.red.shade800;
const highlightColor = Color.fromARGB(255, 157, 0, 255);

double appBarHeight(BuildContext context) {
  if (isTablet(context)) {
    return appBarSizeDesktop;
  } else {
    return appBarSize;
  }
}

bool isTablet(BuildContext context) {
  return MediaQuery.sizeOf(context).width <= 1600;
}

class AppColors {
  Color highLightColor(BuildContext context) =>
      Theme.of(context).highlightColor;

  Color textColor(BuildContext context) =>
      Theme.of(context).colorScheme.inversePrimary;

  Color backroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  Color foregroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.inversePrimary;
}

class ElevatedButtonStyles {
  final buttonLarge = ButtonStyle(
    textStyle: WidgetStatePropertyAll(TextStyles().textXlBold),
    elevation: const WidgetStatePropertyAll(0),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 24.0,
      ),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRad().bRadiusLg,
      ),
    ),
  );

  final buttonMedium = ButtonStyle(
    textStyle: WidgetStatePropertyAll(TextStyles().textLgBold),
    elevation: const WidgetStatePropertyAll(0),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
    ),
    shape: WidgetStatePropertyAll(
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
  final textXlBold = const TextStyle(
    fontSize: fontSizeXl,
    fontWeight: FontWeight.bold,
    letterSpacing: largeLetterSpace,
  );

  final textXl = const TextStyle(
    fontSize: fontSizeXl,
    letterSpacing: largeLetterSpace,
  );

  final textLgBold = const TextStyle(
    fontSize: fontSizeLg,
    fontWeight: FontWeight.bold,
    letterSpacing: mediumLetterSpace,
  );

  final textLg = const TextStyle(
    fontSize: fontSizeLg,
    letterSpacing: mediumLetterSpace,
  );

  final textMdBold = const TextStyle(
    fontSize: fontSizeMd,
    fontWeight: FontWeight.bold,
  );

  final textMd = const TextStyle(
    fontSize: fontSizeMd,
  );

  final textSm = const TextStyle(
    fontSize: fontSizeSm,
  );

  final textSmBold = const TextStyle(
    fontSize: fontSizeSm,
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

Widget backDropFilter(BuildContext context) {
  return ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        height: appBarSize,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.surface
            ],
          ),
          // color: Colors.transparent,
        ),
        // height: 124,
      ),
    ),
  );
}

double imageWidth(BuildContext context) {
  return MediaQuery.sizeOf(context).width <= 1024 ? 650 : 800;
}
