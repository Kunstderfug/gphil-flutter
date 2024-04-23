import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_movement.dart';
import 'package:gphil/providers/session_provider.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ScoreMovements extends StatelessWidget {
  final List<Movement> movements;
  const ScoreMovements({super.key, required this.movements});

  @override
  Widget build(BuildContext context) {
    final scoreProvider = Provider.of<ScoreProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final Movement movement in movements)
          ScoreMovement(
            movement: movement,
            isSelected:
                scoreProvider.movementIndex == movements.indexOf(movement),
            onTap: () =>
                scoreProvider.setMovementIndex(movements.indexOf(movement)),
          ),

        //helper text
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(Icons.arrow_upward_sharp,
                  color: Theme.of(context).colorScheme.secondary, size: 24),
            ),
            Text('Tap on the + button', style: TextStyles().textXSmall),
            Text(
              'to add a movement to the performance playlist',
              style: TextStyles().textXSmall,
            ),
            const SeparatorLine(),
          ],
        ),

        //current playlist info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Performance Playlist', style: TextStyles().textSmallBold),
                const SizedBox(width: 12),
                Expanded(
                    child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: sessionProvider.sessionPlaylist.isEmpty
                        ? MaterialStateProperty.all(
                            Theme.of(context).colorScheme.primary)
                        : MaterialStateProperty.all(
                            Theme.of(context).highlightColor),
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.inversePrimary),
                  ),
                  onPressed: () => sessionProvider.sessionPlaylist.isEmpty
                      ? null
                      : sessionProvider.startSession(),
                  child: Ink(
                    child: Text(
                      sessionProvider.sessionPlaylist.isEmpty
                          ? 'Playlist Empty'
                          : 'Start Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: sessionProvider.sessionPlaylist.isEmpty
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                )),
              ],
            ),
            Text(
              sessionProvider.sessionComposer,
              style: TextStyles().textSmall,
            ),
            for (final movement in sessionProvider.sessionMovements)
              Text(movement.title, style: TextStyles().textXSmall),
          ],
        ),
      ],
    );
  }
}
