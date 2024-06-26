import 'package:flutter/material.dart';
import 'package:gphil/components/library/score_progress_indicator.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LibraryItemCard extends StatelessWidget {
  final LibraryItem libraryItem;

  const LibraryItemCard({super.key, required this.libraryItem});

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final s = Provider.of<ScoreProvider>(context, listen: false);
    final l = Provider.of<LibraryProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: SizedBox(
        height: sizeLg,
        child: InkWell(
          hoverColor: Theme.of(context).highlightColor,
          borderRadius: BorderRadius.circular(32),
          onTap: () async {
            s.setCurrentScoreIdAndRevision(libraryItem.id, libraryItem.rev);
            l.setScoreId(libraryItem.id);
            await s.getScore(libraryItem.id);
            n.setNavigationIndex(2);
          },
          child: Stack(alignment: Alignment.bottomLeft, children: [
            if (libraryItem.complete < 100)
              ScoreProgressIndicator(complete: libraryItem.complete)
            else
              Positioned(
                top: 8,
                right: 16,
                child: Icon(
                  Icons.check_circle_outline,
                  color: greenColor,
                  size: iconSizeXs,
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: paddingLg, vertical: paddingSm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  libraryItem.shortTitle,
                  style: TextStyles().textSm,
                ),
              ),
            ),
            if (s.isLoading && s.scoreId == libraryItem.id)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingLg),
                child: LinearProgressIndicator(
                  minHeight: 2,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  backgroundColor: highlightColor,
                ),
              ),
          ]),
        ),
      ),
    );
  }
}
