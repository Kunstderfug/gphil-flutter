import 'package:flutter/material.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ShowPrompt extends StatelessWidget {
  const ShowPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final s = Provider.of<ScoreProvider>(context);

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
      style: buttonStyle(redColor, context),
      onPressed: () {
        p.clearSession();
        p.addMovement(s.currentScore!, p.movementToAdd!);
      },
      icon: Icon(Icons.check, color: redColor),
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
        style: buttonStyle(greenColor, context),
        onPressed: () => p.closePrompt(),
        icon: Icon(Icons.close_sharp, color: greenColor));

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Replace a concerto?',
          style: TextStyles().textLg,
        ),
        const SizedBox(height: separatorXs),
        Text(
          'You already have a score in your session',
          textAlign: TextAlign.center,
          style: TextStyles().textMd,
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
      ],
    );

    return AnimatedOpacity(
      opacity: p.showPrompt ? 0.97 : 0,
      duration: const Duration(milliseconds: 300),
      child: Dialog(
        alignment: Alignment.topCenter,
        child: Container(
          width: 600,
          height: 340,
          padding: const EdgeInsets.all(paddingXl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.onPrimary,
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            // border: Border.all(color: redColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              content,
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    clearSession,
                    closePrompt,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
