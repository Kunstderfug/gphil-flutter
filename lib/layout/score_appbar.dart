import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_links.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';

class ScoreAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ScoreProvider s;

  const ScoreAppBar({super.key, required this.s});

  @override
  Size get preferredSize => const Size.fromHeight(appBarSizeDesktop);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: paddingMd, right: paddingMd),
        child: Stack(
          fit: StackFit.passthrough,
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.currentScore?.composer.toUpperCase() ?? '',
                    style: const TextStyle(
                      fontSize: fontSizeMd,
                      letterSpacing: 2,
                      wordSpacing: 4,
                    )),
                Text('${s.currentScore?.shortTitle.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: fontSizeMd,
                      letterSpacing: 2,
                      wordSpacing: 4,
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScoreLinks(
                    pianoScoreUrl: s.currentScore?.pianoScoreUrl,
                    fullScoreUrl: s.currentScore?.fullScoreUrl),
              ],
            ),
          ],
        ),
      ),
      toolbarHeight: appBarSizeDesktop,
    );
  }
}
