import 'package:flutter/material.dart';
import 'package:gphil/theme/constants.dart';

class ScoreLinks extends StatelessWidget {
  final String? fullScoreUrl;
  final String? pianoScoreUrl;

  const ScoreLinks({
    super.key,
    this.fullScoreUrl,
    this.pianoScoreUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        fullScoreUrl == null
            ? TextButton(
                onPressed: () {},
                child: Text('Full Score',
                    style: TextStyle(
                      fontSize: fontSizeSm,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    )),
              )
            : const Text(''),
        const SizedBox(width: 16),
        const Text('|'),
        const SizedBox(width: 16),
        fullScoreUrl == null
            ? TextButton(
                onPressed: () {},
                child: Text('Piano Score',
                    style: TextStyle(
                      fontSize: fontSizeSm,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    )),
              )
            : const Text(''),
      ],
    );
  }
}
