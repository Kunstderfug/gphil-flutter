import 'package:flutter/material.dart';
import 'package:gphil/components/score/section_image.dart';

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(child: SectionImage()),
      ],
    );
  }
}
