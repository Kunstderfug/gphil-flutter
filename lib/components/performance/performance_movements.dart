import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceMovements extends StatelessWidget {
  final List<SessionMovement> movements;
  const PerformanceMovements({super.key, required this.movements});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (SessionMovement movement in movements)
          Selector<PlaylistProvider, String?>(
            selector: (_, provider) => provider.currentMovementKey,
            builder: (context, currentMovementKey, _) {
              return Container(
                decoration:
                    BoxDecoration(border: Border.all(color: highlightColor)),
                child: ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  selected: movement.movementKey == currentMovementKey,
                  selectedTileColor: highlightColor,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  title: Text(movement.title,
                      style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Provider.of<PlaylistProvider>(context, listen: false)
                        .setMovementIndexByKey(movement.movementKey);
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
