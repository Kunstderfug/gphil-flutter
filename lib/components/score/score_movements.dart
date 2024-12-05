import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_movement.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ScoreMovements extends StatelessWidget {
  final List<Movement> movements;
  const ScoreMovements({super.key, required this.movements});

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<ScoreProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);
    final n = Provider.of<NavigationProvider>(context, listen: false);

    void startSession() {
      p.buildPlaylist(s.currentScore!);
      // p.loadClickFiles(p.playlist);
      p.initSessionPlayers(p.playlist.first.key);
      n.setNavigationIndex(1);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final Movement movement in movements)
          ScoreMovement(
            movement: movement,
            isSelected: s.movementIndex == movements.indexOf(movement),
            onTap: () {
              s.setMovementIndex(movements.indexOf(movement));
            },
          ),

        //helper text
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: paddingSm),
              child: Icon(Icons.arrow_upward_sharp,
                  color: greenColor, size: iconSizeSm),
            ),
            Text(
                'Tap on the + button\nto add a movement to the performance playlist',
                textAlign: TextAlign.end,
                style: TextStyles().textSm),
            const SeparatorLine(),
          ],
        ),

        //current playlist info
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Practice Playlist', style: TextStyles().textMdBold),
                const SizedBox(width: separatorSm),
                isTablet(context)
                    ? Expanded(
                        child: Opacity(
                          opacity: !p.containsMovement(s.currentMovement.key)
                              ? 0.4
                              : 1,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: p.playlist.isEmpty
                                  ? WidgetStateProperty.all(
                                      Theme.of(context).colorScheme.primary)
                                  : WidgetStateProperty.all(greenColor),
                              foregroundColor: WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.inversePrimary),
                            ),
                            onPressed: () =>
                                p.playlist.isEmpty ? null : startSession(),
                            child: Ink(
                              child: Text(
                                p.playlist.isEmpty
                                    ? 'Playlist Empty'
                                    : 'Start Session',
                                style: TextStyle(
                                  fontSize: fontSizeMd,
                                  fontWeight: FontWeight.bold,
                                  color: p.playlist.isEmpty
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : TextButton(
                        style: ButtonStyle(
                          // fixedSize: const WidgetStatePropertyAll(Size(170, 0)),
                          backgroundColor: p.sessionMovements.isEmpty
                              ? WidgetStateProperty.all(
                                  Theme.of(context).colorScheme.primary)
                              : WidgetStateProperty.all(greenColor),
                          foregroundColor: WidgetStateProperty.all(
                              Theme.of(context).colorScheme.inversePrimary),
                        ),
                        onPressed: () =>
                            p.sessionMovements.isEmpty ? null : startSession(),
                        child: Ink(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: paddingMd, vertical: paddingSm),
                            child: Text(
                              p.sessionMovements.isEmpty
                                  ? 'Playlist Empty'
                                  : 'Start Session',
                              style: TextStyle(
                                fontSize: fontSizeMd,
                                color: p.sessionMovements.isEmpty
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: separatorXs),
            Text(
              '${p.sessionScore?.composer ?? 'Playlist Empty'}${p.sessionScore != null ? ' - ' : ''}${p.sessionScore?.shortTitle ?? ''}',
              style: TextStyles().textMd,
            ),
            SizedBox(
              height: 18,
              child: Wrap(
                spacing: 8,
                children: [
                  for (final movement in p.sessionMovements)
                    Text(
                      '${movement.title}${p.sessionMovements.indexOf(movement) < p.sessionMovements.length - 1 ? ', ' : ''}',
                      style: TextStyles().textSm,
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
