import 'package:flutter/material.dart';
import 'package:gphil/components/library/score_progress_indicator.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:provider/provider.dart';

class LibraryItemCard extends StatelessWidget {
  final LibraryItem scoreCard;

  const LibraryItemCard({super.key, required this.scoreCard});

  @override
  Widget build(BuildContext context) {
    final navigator = Provider.of<NavigationProvider>(context);
    final scoreProvider = Provider.of<ScoreProvider>(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          scoreProvider.scoreId = scoreCard.id;
          await scoreProvider.getScore();
          navigator.setNavigationIndex(3);
        },
        child: Stack(alignment: Alignment.topCenter, children: [
          ScoreProgressIndicator(complete: scoreCard.complete),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                scoreCard.composer,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                scoreCard.shortTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          if (scoreProvider.isLoading && scoreProvider.scoreId == scoreCard.id)
            const LinearProgressIndicator(
              backgroundColor: Color.fromARGB(255, 159, 33, 243),
            ),
        ]),
      ),
    );
  }
}
