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
    final p = Provider.of<PlaylistProvider>(context);

    return Column(
      children: [
        for (SessionMovement movement in movements)
          Container(
            decoration:
                BoxDecoration(border: Border.all(color: highlightColor)),
            child: ListTile(
              selected: movement.movementKey == p.currentMovementKey,
              selectedTileColor: highlightColor,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              title:
                  Text(movement.title, style: TextStyle(color: Colors.white)),
              onTap: () {
                p.setMovementIndexByKey(movement.movementKey);
              },
            ),
          ),
      ],
    );
  }
}
