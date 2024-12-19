import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

double scale(BuildContext context) => isHiDPI(context) ? 1.25 : 1.0;

//sizes
const sizeXxs = 4.0;
const sizeXs = 8.0;
const sizeSm = 12.0;
const sizeMd = 16.0;
const sizeLg = 24.0;
const sizeXl = 32.0;
const sizeXxl = 48.0;

//paddings
const paddingXs = 4.0;
const paddingSm = 8.0;
const paddingMd = 16.0;
const paddingLg = 24.0;
const paddingXl = 32.0;

//icon sizes
const iconSizeXs = 16.0;
const iconSizeSm = 24.0;
const iconSizeMd = 32.0;
const iconSizeLg = 48.0;
const iconSizeXl = 64.0;

//separators
const separatorXs = 16.0;
const separatorSm = 24.0;
const separatorMd = 32.0;
const separatorLg = 48.0;
const separatorXl = 64.0;
const separatorThickness = 2.0;

//app bar
const appBarSize = 84.0;
const appBarSizeDesktop = 44.0;

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
// final greenColor = Color(0xFF008B76);
final greenColor = AppColors.darkGreen;
final redColor = Colors.red.shade800;
const highlightColor = Color.fromARGB(255, 86, 0, 170);

double appBarHeight(BuildContext context) {
  if (isTablet(context)) {
    return appBarSizeDesktop;
  } else {
    return appBarSize;
  }
}

bool isTablet(BuildContext context) {
  return MediaQuery.sizeOf(context).width <= 980;
}

bool isHiDPI(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= 2560;
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

  static Color greenColor = Colors.green.shade600;
  static const Color mutedGreen = Color.fromARGB(255, 191, 255, 0);
  static const Color deepJungleGreen = Color(0xFF006D5B);
  static const Color pineGreen = Color(0xFF00796B);
  static const Color persianGreen = Color(0xFF00897B);
  static const Color teal = Color(0xFF009688);
  static const Color keppel = Color(0xFF26A69A);
  static const Color deepTeal = Color(0xFF004D40);
  static const Color tropicalRainForest = Color(0xFF00695C);
  static const Color bottleGreen = Color(0xFF00796B);
  static const Color blueStone = Color(0xFF00838F);
  static const Color midnightGreen = Color(0xFF006064);
  static const Color emeraldGreen = Color(0xFF50C878);
  static const Color forestGreen = Color(0xFF1B5E20);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color green = Color(0xFF388E3C);
  static const Color mediumGreen = Color(0xFF43A047);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color limeGreen = Color(0xFF66BB6A);
  static Color limeGreen1 = Color(0xFF00FF00);
  static const Color paleGreen = Color(0xFF81C784);
  static const Color tealGreen = Color(0xFF00695C);
  static const Color deepGreen = Color(0xFF004D40);
  static const Color deepGreenTeal = Color.fromARGB(255, 22, 104, 88);

  static const Color tyrianPurple = Color(0xFF4A0E4E);
  static const Color indigoPurple = Color(0xFF5E2D79);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color deepPurple = Color(0xFF8E24AA);
  static const Color mediumPurple = Color(0xFF9C27B0);
  static const Color orchidPurple = Color(0xFFAB47BC);
  static const Color lightPurple = Color(0xFFBA68C8);
  static const Color royalPurple = Color(0xFF6A1B9A);
  static const Color deepViolet = Color(0xFF4A148C);
  static const Color lavender = Color(0xFFD1C4E9);
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
  const SeparatorLine(
      {super.key,
      this.height = separatorMd,
      this.color = Colors.grey,
      this.opacity = 0.2});
  final double height;
  final Color color;
  final double opacity;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Container(
          height: separatorThickness,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
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

ButtonStyle buttonStyle(Color color, BuildContext context) =>
    TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      side: BorderSide(color: color),
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
    );

double imageWidth(BuildContext context) {
  return MediaQuery.sizeOf(context).width <= 899 ? 500 : 600;
}

double maxLaptopWidth = 2560;
