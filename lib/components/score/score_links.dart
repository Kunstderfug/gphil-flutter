import 'package:flutter/material.dart';

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
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: fullScoreUrl == null
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Full Score'),
                )
              : const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(''),
                ),
        ),
        const SizedBox(width: 16),
        const Text('|'),
        const SizedBox(width: 16),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: fullScoreUrl == null
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Piano Score'),
                )
              : const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(''),
                ),
        ),
      ],
    );
  }
}
