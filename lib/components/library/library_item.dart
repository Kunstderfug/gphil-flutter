// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gphil/components/library/score_progress_indicator.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class LibraryItemCard extends StatelessWidget {
  final LibraryItem libraryItem;

  const LibraryItemCard({super.key, required this.libraryItem});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppConnection>(
      builder: (context, ac, child) {
        final n = Provider.of<NavigationProvider>(context);
        final s = Provider.of<ScoreProvider>(context, listen: false);
        final l = Provider.of<LibraryProvider>(context, listen: false);

        Future<bool> isScoreAvailableOffline() async {
          final p = PersistentDataController();

          return await p.readScoreData(libraryItem.id) != null;
        }

        Future<void> setScore() async {
          final bool isOffline = ac.appState == AppState.offline;
          final bool scoreAvailable = await isScoreAvailableOffline();

          if (isOffline && !scoreAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Score not available offline'),
                backgroundColor: redColor,
              ),
            );
            return;
          }

          s.setCurrentScoreIdAndRevision(libraryItem.id, libraryItem.rev);
          l.setScoreId(libraryItem.id);
          await s.getScore(libraryItem.id);
          n.setScoreScreen();
          l.addToRecentlyAccessed(libraryItem);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: SizedBox(
            height: sizeLg,
            child: InkWell(
              hoverColor: highlightColor,
              borderRadius: BorderRadius.circular(32),
              onTap: setScore,
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  if (libraryItem.complete < 100)
                    ScoreProgressIndicator(complete: libraryItem.complete)
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: paddingMd),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.check_circle_outline,
                          color: greenColor,
                          size: iconSizeXs,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: paddingLg),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        // softWrap: true,
                        overflow: TextOverflow.fade,
                        libraryItem.shortTitle,
                        style: TextStyles().textSm,
                        textScaler: const TextScaler.linear(1.1),
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
                  if (ac.appState == AppState.offline)
                    FutureBuilder<bool>(
                      future: isScoreAvailableOffline(),
                      builder: (context, snapshot) {
                        final bool available = snapshot.data ?? false;
                        return Padding(
                          padding: const EdgeInsets.only(right: paddingMd),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              available
                                  ? Icons.offline_pin
                                  : Icons.offline_bolt,
                              color: available ? greenColor : redColor,
                              size: iconSizeXs,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
