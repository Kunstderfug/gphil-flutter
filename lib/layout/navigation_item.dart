import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class NavigationItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final int index;
  const NavigationItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.index});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    bool isSelected = n.currentIndex == index;

    return Padding(
      padding: const EdgeInsets.only(left: paddingLg, top: paddingLg),
      child: ListTile(
        title: Text(title, style: TextStyles().textSm),
        leading: Icon(
          icon,
          size: iconSizeSm,
        ),
        selected: isSelected,
        selectedTileColor: isSelected
            ? AppColors().highLightColor(context)
            : Colors.transparent,
        onTap: () {
          n.setNavigationIndex(index);
        },
      ),
    );
  }
}
