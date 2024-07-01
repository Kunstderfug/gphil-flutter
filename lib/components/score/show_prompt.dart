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
    final s = Provider.of<ScoreProvider>(context);

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
        padding: const EdgeInsets.all(paddingSm),
        child: Text(
          'Yes, replace',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSizeMd,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
      style: buttonStyle,
      onPressed: () {
        p.clearSession();
        p.addMovement(s.currentScore!, p.movementToAdd!, s.currentSection.key);
      },
      icon: Icon(Icons.check, color: greenColor),
    );

    Widget closePrompt = ElevatedButton.icon(
        iconAlignment: IconAlignment.end,
        label: Padding(
          padding: const EdgeInsets.all(paddingSm),
          child: Text(
            'No, close window',
            style: TextStyle(
              fontSize: fontSizeMd,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ),
        style: buttonStyle,
        onPressed: () => p.closePrompt(),
        icon: Icon(Icons.close_sharp, color: redColor));

    return AnimatedOpacity(
      opacity: p.showPrompt ? 0.97 : 0,
      duration: const Duration(milliseconds: 300),
      child: AlertDialog(
        alignment: Alignment.topCenter,
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        backgroundColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.all(paddingXl * 1.5),
        iconColor: highlightColor,
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
            const SizedBox(height: separatorXl),
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
