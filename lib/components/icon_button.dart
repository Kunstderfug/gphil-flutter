import 'package:flutter/material.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/mdi_light.dart';
import 'package:iconify_flutter_plus/icons/system_uicons.dart';
import 'package:iconify_flutter_plus/icons/heroicons.dart';
import 'package:iconify_flutter_plus/icons/arcticons.dart';

final hero = Heroicons;
final mdi = MdiLight;
final systemUicons = SystemUicons;
final arcticons = Arcticons;

enum IconSet {
  mdi,
  systemUicons,
  heroicons,
  arcticons,
}

class IconB extends StatelessWidget {
  const IconB({
    super.key,
    this.iconColor,
    // required this.iconSet,
    required this.iconName,
    this.iconAlignment = IconAlignment.start,
    required this.callback,
    this.size = 20,
  });

  final Color? iconColor;
  final IconAlignment iconAlignment;
  final Function() callback;
  // final IconSet iconSet;
  final String iconName;
  final double size;

  // String _getIconData() {
  //   switch (iconSet) {
  //     case IconSet.mdi:
  //       return 'mdi-light:$iconName';
  //     case IconSet.systemUicons:
  //       return 'system-uicons:$iconName';
  //     case IconSet.heroicons:
  //       return 'heroicons:$iconName';
  //     case IconSet.arcticons:
  //       return 'arcticons:$iconName';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: callback,
      padding: const EdgeInsets.all(0),
      iconSize: size,
      icon: Iconify(
        iconName,
        color: iconColor,
        size: size,
      ),
    );
  }
}
