import 'package:flutter/material.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ScoreMovement extends StatelessWidget {
  final void Function() onTap;
  final bool isSelected;
  final Movement movement;
  const ScoreMovement(
      {super.key,
      required this.onTap,
      required this.isSelected,
      required this.movement});

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<ScoreProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRad().bRadiusXl,
                color: isSelected
                    ? Theme.of(context).highlightColor.withOpacity(1)
                    : Colors.transparent,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
                child: Text(movement.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    )),
              ),
            ),
          ),
          IconButton(
              style: ButtonStyle(
                backgroundColor: p.containsMovement(movement.key)
                    ? WidgetStateProperty.all(Theme.of(context).highlightColor)
                    : WidgetStateProperty.all(Colors.transparent),
                shape: WidgetStateProperty.all(const CircleBorder()),
              ),
              onPressed: () {
                p.containsMovement(movement.key)
                    ? p.removeMovement(movement)
                    : p.addMovement(s.currentScore!, movement);
              },
              tooltip: p.containsMovement(movement.key)
                  ? 'Remove movement from the playlist'
                  : 'Add movement to the playlist',
              icon: Icon(
                size: iconSizeSm * 1.2,
                p.containsMovement(movement.key) ? Icons.check : Icons.add,
                color: p.containsMovement(movement.key)
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Theme.of(context).highlightColor,
              )),
        ],
      ),
    );
  }
}
