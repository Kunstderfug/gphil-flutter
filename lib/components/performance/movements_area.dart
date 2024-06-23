import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:provider/provider.dart';

class MovementsArea extends StatelessWidget {
  const MovementsArea({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<ScoreProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);

    return Wrap(
      spacing: 32,
      children: [
        for (SessionMovement movement in p.sessionMovements)
          IconButton(
              onPressed: () {
                p.setMovementIndexByKey(movement.movementKey);
                s.setCurrentSectionByKey(
                    movement.movementKey, p.currentSectionKey!);
              },
              padding: EdgeInsets.zero,
              hoverColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.5),
              icon: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(32)),
                  color: movement.movementKey == p.currentMovementKey
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.transparent,
                ),
                child: Text(
                  movement.title,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              )),
      ],
    );
  }
}
