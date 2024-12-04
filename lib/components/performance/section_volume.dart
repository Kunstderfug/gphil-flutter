import 'package:flutter/material.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class SectionVolume extends StatelessWidget {
  final double sectionVolume;
  final Section section;
  const SectionVolume(
      {super.key, required this.section, required this.sectionVolume});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    return SizedBox(
      height: 235,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 160,
                child: SfSliderTheme(
                  data: SfSliderThemeData(
                    thumbColor: highlightColor,
                    activeTrackColor: p.setColor(),
                    inactiveTrackColor: p.setInactiveColor(),
                    activeTrackHeight: 4,
                    inactiveTrackHeight: 4,
                    thumbRadius: 6,
                    thumbStrokeColor: p.layersEnabled ? greenColor : null,
                    thumbStrokeWidth: 1,
                    tooltipBackgroundColor:
                        p.layersEnabled ? highlightColor : null,
                    tooltipTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  child: InkWell(
                    onDoubleTap: () => p.resetSectionVolume(p.currentSection!),
                    child: SfSlider.vertical(
                        min: 0.0,
                        max: 2.0,
                        interval: 0.5,
                        stepSize: 0.1,
                        showTicks: true,
                        showLabels: true,
                        minorTicksPerInterval: 1,
                        activeColor: p.setColor(),
                        inactiveColor: p.setInactiveColor(),
                        enableTooltip: true,
                        value: sectionVolume,
                        onChangeEnd: (value) => p.saveSectionPrefs(section),
                        onChanged: (value) =>
                            p.setSectionVolume(section, value)),
                  ),
                ),
              ),
              InkWell(
                onDoubleTap: () => p.resetSectionVolume(p.currentSection!),
                child: Column(
                  children: [
                    Text(
                      'Section volume: ${p.currentSection!.sectionVolume}',
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                    Text(
                      '(Double-click to reset)',
                      style: TextStyle(
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
              ),

              // SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('reset all',
                      style: TextStyle(
                        fontSize: 10.0,
                      )),
                  SizedBox(width: 4),
                  SizedBox.square(
                    dimension: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero, // Remove padding
                      constraints:
                          BoxConstraints(), // Remove default constraints
                      tooltip:
                          'Reset volume for all sections in the current movement',
                      icon: Icon(Icons.refresh_sharp),
                      iconSize: 16.0,
                      color: p.setColor(),
                      splashRadius: 8.0,
                      onPressed: () {
                        p.resetAllSectionsVolume();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('All section volumes have been reset'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            width: 280.0,
                            action: SnackBarAction(
                              label: 'OK',
                              textColor: greenColor,
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
