import 'package:flutter/material.dart';

class ScoreProgressIndicator extends StatelessWidget {
  final int complete;
  const ScoreProgressIndicator({super.key, required this.complete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LinearProgressIndicator(
        minHeight: 2,
        value: complete / 100,
        color: Theme.of(context).highlightColor,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }
}
