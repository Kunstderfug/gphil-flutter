import 'package:flutter/material.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/providers/playlist_provider.dart';
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
      padding: const EdgeInsets.only(bottom: paddingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRad().bRadiusXl,
                color: isSelected
                    ? AppColors().highLightColor(context)
                    : Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: paddingSm, horizontal: paddingLg),
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
                    ? WidgetStateProperty.all(greenColor)
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
                size: iconSizeXs,
                p.containsMovement(movement.key) ? Icons.check : Icons.add,
                color: p.containsMovement(movement.key)
                    ? Theme.of(context).colorScheme.inversePrimary
                    : greenColor,
              )),
        ],
      ),
    );
  }
}
