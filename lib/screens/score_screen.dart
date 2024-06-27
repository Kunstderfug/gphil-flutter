import 'package:flutter/material.dart';
import 'package:gphil/components/library/score_navigation.dart';
import 'package:gphil/components/score/section_image.dart';
import 'package:gphil/components/score/score_movements.dart';
import 'package:gphil/components/score/score_sections.dart';
import 'package:gphil/components/score/section_tempos.dart';
import 'package:gphil/components/score/show_prompt.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

final persistentController = PersistentDataController();

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LibraryProvider>(context, listen: false);
    return FutureBuilder(
      future: Provider.of<ScoreProvider>(context, listen: false)
          .getScore(l.currentScoreId),
      builder: (context, snapshot) {
        return Consumer<ScoreProvider>(builder: (context, s, child) {
          //s ScoreProvider
          final p = Provider.of<PlaylistProvider>(context);
          final n = Provider.of<NavigationProvider>(context);
          if (s.currentScore == null) {
            return Center(child: Text(s.error));
          } else {
            return Stack(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScoreNavigation(s: s, n: n, p: p),

                        const SizedBox(height: separatorXs),

                        //MOVEMENTS % SECTIONS HEADING
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('M O V E M E N T S',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SeparatorLine(),
                                ],
                              ),
                            ),
                            const SizedBox(width: separatorLg),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('S E C T I O N S',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium),
                                      if (!s.scoreIsUptoDate)
                                        Text('Update available',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                    ],
                                  ),
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
                              flex: 2,
                              child:
                                  ScoreMovements(movements: s.currentMovements),
                            ),
                            const SizedBox(width: separatorLg),

                            //SECTIONS
                            Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    ScoreSections(
                                      sections: s.currentSections,
                                    ),
                                    //SECTION IMAGE
                                    SizedBox(
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                  height: separatorMd),
                                              Text('Section starts at:',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium),
                                              const SizedBox(
                                                  height: separatorXs),
                                              SectionImage(
                                                  imageFile: s.sectionImageFile,
                                                  width: 250),
                                              const SizedBox(
                                                  height: separatorXs),
                                              SectionTempos(
                                                  section: s.currentSection),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                          ],
                        ),

                        const SizedBox(height: separatorXs),
                      ]),
                ],
              ),
              if (p.showPrompt) const ShowPrompt(),
            ]);
          }
        });
      },
    );
  }
}
