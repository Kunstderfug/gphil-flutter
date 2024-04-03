// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:provider/provider.dart';

class ScoreSections extends StatelessWidget {
  final List<SetupSection> sections;
  const ScoreSections({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoreProvider>(builder: (context, provider, child) {
      // log('score_sections: ${provider.currentSections}');

      if (provider.currentSections == null) {
        return const Center(child: Text('No sections found'));
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: [
            Text('S E C T I O N S',
                style: Theme.of(context).textTheme.titleLarge),
            SizedBox(
              height: 52,
              child: Center(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (var section in sections)
                  InkWell(
                    // borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      provider.setCurrentSection(sections.indexOf(section));
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(16),
                        color:
                            provider.sectionIndex == sections.indexOf(section)
                                ? Theme.of(context).highlightColor
                                : Colors.transparent,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        child: Text(section.name),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        );
      }
    });
  }
}
