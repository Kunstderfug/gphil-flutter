import 'package:flutter/material.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:provider/provider.dart';

class ScoreMovements extends StatelessWidget {
  final List<SetupMovement> movements;
  const ScoreMovements({super.key, required this.movements});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScoreProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('M O V E M E N T S',
            style: Theme.of(context).textTheme.titleLarge),
        SizedBox(
          height: 52,
          child: Center(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
              ),
            ),
          ),
        ),
        Wrap(
          direction: Axis.vertical,
          spacing: 16,
          runSpacing: 16,
          children: [
            for (SetupMovement movement in movements)
              InkWell(
                // borderRadius: BorderRadius.circular(16),
                onTap: () {
                  provider.setMovementIndex(movements.indexOf(movement));
                },
                child: Ink(
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(16),
                    color: provider.movementIndex == movements.indexOf(movement)
                        ? Theme.of(context).highlightColor
                        : Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    child: Text(movement.title),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
