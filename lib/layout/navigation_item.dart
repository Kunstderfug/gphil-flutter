import 'package:flutter/material.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class NavigationItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final int index;
  final bool isSelected;
  const NavigationItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.index,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(top: paddingLg),
      child: ListTile(
        title: Text(title, style: TextStyles().textSm),
        leading: Icon(
          icon,
          size: iconSizeSm,
        ),
        selected: isSelected,
        selectedTileColor: isSelected ? highlightColor : Colors.transparent,
        onTap: () {
          n.setNavigationIndex(index);
        },
      ),
    );
  }
}
