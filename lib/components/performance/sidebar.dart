import 'package:flutter/material.dart';
import 'package:gphil/components/performance/performance_sections.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/performance/tooltip_toggle.dart';
import 'package:gphil/models/playlist_classes.dart';
// import 'package:gphil/providers/global_providers.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
// import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceSidebar extends StatelessWidget {
  const PerformanceSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    List<SessionMovement> movements = p.sessionMovements;

    isExpanded(movement) => p.currentMovementKey == movement.movementKey;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Movements",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height - 185,
            child: ListView.builder(
              itemCount: movements.length,
              itemBuilder: (context, index) {
                final movement = movements[index];
                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: highlightColor)),
                      height: isExpanded(movement) ? null : 64,
                      child: ListTile(
                        selected: isExpanded(movement),
                        selectedTileColor: highlightColor,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Icon(
                          isExpanded(movement)
                              ? Icons.expand_more
                              : Icons.chevron_right,
                          color: Colors.white70,
                        ),
                        title: Text(movement.title,
                            style: TextStyle(color: Colors.white)),
                        onTap: () {
                          p.setMovementIndexByKey(movement.movementKey);
                        },
                      ),
                    ),
                    SizedBox(height: sizeSm),
                    if (isExpanded(movement))
                      PerformanceSections(sections: p.currentMovementSections),
                    SizedBox(height: sizeSm),
                  ],
                );
              },
            ),
          ),
        ),
        Row(children: []),
      ],
    );
  }
}
