import 'package:flutter/material.dart';

class ScoreProgressIndicator extends StatelessWidget {
  final int complete;
  const ScoreProgressIndicator({super.key, required this.complete});

  @override
  Widget build(BuildContext context) {
    if (complete != 100) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: LinearProgressIndicator(
          value: complete / 100,
          color: Theme.of(context).highlightColor,
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
      );
    } else {
      return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                  size: 24,
                  color: Theme.of(context).highlightColor,
                  Icons.check_circle_outline),
            )
          ]);
    }
  }
}
