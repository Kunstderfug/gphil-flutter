import 'package:flutter/material.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/session_provider.dart';
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
    final scoreProvider = Provider.of<ScoreProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            borderRadius: BorderRad().bRadiusXl,
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRad().bRadiusXl,
                color: isSelected
                    ? Theme.of(context).highlightColor
                    : Colors.transparent,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: Text(movement.title),
              ),
            ),
          ),
          IconButton(
              style: ButtonStyle(
                backgroundColor: sessionProvider.containsMovement(movement)
                    ? MaterialStateProperty.all(
                        Theme.of(context).highlightColor)
                    : MaterialStateProperty.all(Colors.transparent),
                shape: MaterialStateProperty.all(const CircleBorder()),
              ),
              onPressed: () {
                sessionProvider.containsMovement(movement)
                    ? sessionProvider.removeMovement(movement)
                    : sessionProvider.addMovement(
                        scoreProvider.currentScore!, movement);
              },
              tooltip: sessionProvider.containsMovement(movement)
                  ? 'Remove movement from the playlist'
                  : 'Add movement to the playlist',
              icon: Icon(
                size: iconSize * 1.2,
                sessionProvider.containsMovement(movement)
                    ? Icons.check
                    : Icons.add,
                color: sessionProvider.containsMovement(movement)
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Theme.of(context).highlightColor,
              )),
        ],
      ),
    );
  }
}
