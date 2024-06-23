import 'package:flutter/material.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ShowPrompt extends StatelessWidget {
  const ShowPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final score = Provider.of<ScoreProvider>(context);

    final ButtonStyle buttonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
    );

    Widget clearSession = ElevatedButton.icon(
      iconAlignment: IconAlignment.end,
      label: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Yes, replace',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
      style: buttonStyle,
      onPressed: () {
        p.clearSession();
        p.addMovement(score.currentScore!, p.movementToAdd!);
      },
      icon: const Icon(Icons.check),
    );

    Widget closePrompt = ElevatedButton.icon(
        iconAlignment: IconAlignment.end,
        label: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No, close window',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
        style: buttonStyle,
        onPressed: () => p.closePrompt(),
        icon: const Icon(Icons.close_sharp));

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 200),
      child: AlertDialog(
        alignment: Alignment.topCenter,
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        backgroundColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.all(42),
        iconColor: Theme.of(context).highlightColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You already have a score in your session',
              textAlign: TextAlign.center,
              style: TextStyles().textLg,
            ),
            const SizedBox(height: separatorXs),
            Text(
              '${p.sessionComposer} - ${p.sessionScore?.shortTitle}',
              textAlign: TextAlign.start,
              style: TextStyles().textMd,
            ),
            const SizedBox(height: 16),
            Text(
              'Would you like to replace it?',
              textAlign: TextAlign.center,
              style: TextStyles().textLg,
            ),
            // const SeparatorLine(),
          ],
        ),
        actions: [clearSession, closePrompt],
      ),
    );
  }
}
