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

    return Container(
      margin: EdgeInsets.only(bottom: 1),
      height: calculateHeight(),
      decoration: BoxDecoration(
          color: section.key == p.currentSectionKey
              ? setColor(section).withOpacity(1)
              : setColor(section).withOpacity(isSelected ? 1 : o.opacity),
          border: isSelected
              ? Border.all(
                  color: Colors.white,
                )
              : Border.all(
                  color: section.autoContinue == true ? greenColor : redColor,
                  width: 0.5,
                )),
      child: AnimatedOpacity(
        opacity: section.muted && !p.performanceMode ? 0.5 : 1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: TextButton(
          style: ButtonStyle(
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          onPressed: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Section name
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
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
              //Icon for skip
              Expanded(
                flex: 2,
                child: section.muted
                    ? Icon(
                        Icons.play_disabled,
                        color: !p.performanceMode
                            ? Colors.white
                            : Colors.grey.shade700,
                        size: iconSizeXs,
                      )
                    : SizedBox.shrink(),
              ),
              //Icon for loop
              Expanded(
                flex: 2,
                child: section.looped
                    ? Icon(
                        Icons.loop_sharp,
                        color: !p.performanceMode
                            ? Colors.white
                            : Colors.grey.shade700,
                        size: iconSizeXs,
                      )
                    : SizedBox.shrink(),
              ),
              //Autocontinue icon
              Expanded(
                flex: 2,
                child: section.autoContinue == true
                    ? Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                        size: iconSizeSm,
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
