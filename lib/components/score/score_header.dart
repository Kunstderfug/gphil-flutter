import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_links.dart';

class ScoreHeader extends StatelessWidget {
  final String composer;
  final String title;
  final String? fullScoreUrl;
  final String? pianoScoreUrl;

  const ScoreHeader(
      {super.key,
      required this.composer,
      required this.title,
      this.fullScoreUrl,
      this.pianoScoreUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(composer,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inversePrimary,
                )),
        ScoreLinks(
          fullScoreUrl: fullScoreUrl,
          pianoScoreUrl: pianoScoreUrl,
        ),
        Text(title,
            softWrap: true,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.inversePrimary,
                )),
      ],
    );
  }
}
