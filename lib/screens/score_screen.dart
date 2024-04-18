import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_image.dart';
import 'package:gphil/components/score/score_movements.dart';
import 'package:gphil/components/score/score_sections.dart';
import 'package:gphil/components/score/section_tempos.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({
    super.key,
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  @override
  void initState() {
    super.initState();
    final scoreProvider = Provider.of<ScoreProvider>(context, listen: false);
    scoreProvider.getScore();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoreProvider>(builder: (context, provider, child) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      } else if (provider.currentScore == null) {
        return const Center(child: Text('No score found'));
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () {
                final navigator =
                    Provider.of<NavigationProvider>(context, listen: false);
                navigator.setNavigationIndex(0);
              },
              icon: const Icon(Icons.arrow_back),
            ),

            const SizedBox(height: 18),

            //MOVEMENTS % SECTIONS HEADING
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('M O V E M E N T S',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SeparatorLine(),
                    ],
                  ),
                ),
                const SizedBox(width: separatorLg),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('S E C T I O N S',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SeparatorLine(),
                    ],
                  ),
                ),
              ],
            ),

            // MOVEMENTS AND SECTIONS
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: ScoreMovements(movements: provider.currentMovements),
                ),
                const SizedBox(width: separatorLg),

                //SECTIONS
                Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScoreSections(
                            sections: provider.currentSections,
                          ),
                          const SizedBox(height: separatorSm),
                          Text('Section starts at:',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SeparatorLine(),
                          const SizedBox(height: separatorSm),

                          //SECTION IMAGE
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                const SectionImage(),
                                const SizedBox(height: separatorSm),
                                SectionTempos(
                                    tempos: provider.currentSection.tempoRange),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
              ],
            ),

            const SizedBox(height: separatorLg),
          ],
        );
      }
    });
  }
}
