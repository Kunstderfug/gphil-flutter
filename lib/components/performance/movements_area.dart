import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class MovementsArea extends StatelessWidget {
  const MovementsArea({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    List<Widget> movements = [
      for (SessionMovement movement in p.sessionMovements)
        IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              p.setMovementIndexByKey(movement.movementKey);
            },
            hoverColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            icon: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: paddingLg, vertical: paddingSm),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(32)),
                color: movement.movementKey == p.currentMovementKey
                    ? Theme.of(context).highlightColor
                    : Colors.transparent,
              ),
              child: Text(
                movement.title,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: fontSizeMd,
                    fontWeight: FontWeight.bold),
              ),
            )),
    ];

    return Wrap(
      spacing: 32,
      children: movements,
    );
  }
}
