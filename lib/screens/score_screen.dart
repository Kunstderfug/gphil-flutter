import 'package:flutter/material.dart';
import 'package:gphil/components/score/score_board.dart';
import 'package:gphil/components/score/score_movements.dart';
import 'package:gphil/components/score/score_header.dart';
import 'package:gphil/components/score/score_sections.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  onPressed: () {
                    final navigator =
                        Provider.of<NavigationProvider>(context, listen: false);
                    navigator.setNavigationIndex(0);
                  },
                  icon: const Icon(Icons.arrow_back),
                )),
            ScoreHeader(
              composer: provider.currentScore!.composer,
              title: provider.currentScore!.shortTitle,
            ),
            const SizedBox(height: 32),

            // MOVEMENTS AND SECTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //MOVEMENTS
                Expanded(
                  flex: 1,
                  child: ScoreMovements(
                      movements: provider.currentMovements ?? []),
                ),
                const SizedBox(width: 32),
                //SECTIONS
                Expanded(
                    flex: 2,
                    child: ScoreSections(
                      sections: provider.currentSections!,
                    ))
              ],
            ),

            //SECTIOM IMAGE
            const Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ScoreBoard(),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    });
  }
}
