import 'package:flutter/material.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/opacity_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceSection extends StatelessWidget {
  final Section section;
  final void Function() onTap;
  final bool isSelected;

  const PerformanceSection({
    super.key,
    required this.section,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final o = Provider.of<OpacityProvider>(context);

    double calculateHeight() =>
        (MediaQuery.sizeOf(context).height - 400) /
        p.currentMovementSections.length;

    Color setColor(Section section) =>
        section.autoContinueMarker != null && section.autoContinue != false
            ? greenColor
            : redColor;

    Map<String, int> flex() {
      int flexName = 2;
      int flexIcons = 3;

      if (!section.muted) {
        flexName++;
        flexIcons--;
      }
      return {'name': flexName, 'icons': flexIcons};
    }

    return Container(
      // margin: EdgeInsets.only(bottom: 1),
      height: calculateHeight(),
      decoration: BoxDecoration(
          color: section.key == p.currentSectionKey
              ? setColor(section).withOpacity(1)
              : setColor(section).withOpacity(isSelected ? 1 : o.userOpacity),
          border: isSelected
              ? Border.all(
                  color: Colors.white,
                )
              : Border.all(
                  color: section.autoContinue == true ? greenColor : redColor,
                  width: 0.5,
                )),
      child: TextButton(
        style: ButtonStyle(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          minimumSize:
              WidgetStateProperty.all(Size.fromHeight(double.infinity)),
          padding: WidgetStateProperty.all(EdgeInsets.only(left: 12)),
        ),
        onPressed: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Section name
            Expanded(
              flex: flex()['name']!,
              child: AnimatedOpacity(
                opacity: section.muted && !p.performanceMode ? 0.3 : 1,
                duration: Duration(milliseconds: 300),
                child: Text(
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  isTablet(context)
                      ? section.name.toLowerCase().replaceAll('_', ' ')
                      : section.name.replaceAll('_', ' '),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontSize: fontSizeSm),
                ),
              ),
            ),
            Expanded(
              flex: flex()['icons']!,
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                //Icon for skip
                if (section.muted)
                  Expanded(
                      flex: 1,
                      child: section.muted
                          ? Icon(
                              Icons.play_disabled,
                              color: !p.performanceMode
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              size: iconSizeXs,
                            )
                          : SizedBox.shrink()),
                //Icon for loop
                Expanded(
                    flex: 1,
                    child: section.looped
                        ? Icon(
                            Icons.loop_sharp,
                            color: !p.performanceMode
                                ? Colors.white
                                : Colors.grey.shade700,
                            size: iconSizeXs,
                          )
                        : SizedBox.shrink()),
                //Autocontinue icon
                Expanded(
                    flex: 1,
                    child: section.autoContinue == true
                        ? Icon(
                            Icons.navigate_next,
                            color: Colors.white,
                            size: iconSizeXs,
                          )
                        : SizedBox.shrink()),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
