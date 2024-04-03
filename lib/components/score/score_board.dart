import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_image.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:provider/provider.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoreProvider>(builder: (context, provider, child) {
      return Column(
        children: [
          Center(
            child: SizedBox(
              width: 300,
              child: provider.currentSection == null
                  ? const Text('section not found')
                  : Text(provider.currentSection!.name),
            ),
          ),
          const SizedBox(height: 16),
          const ScoreImage(),
        ],
      );
    });
  }
}
