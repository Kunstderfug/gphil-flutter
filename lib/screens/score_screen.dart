import 'package:flutter/material.dart';
import 'package:gphil/components/library/score_navigation.dart';
import 'package:gphil/components/score/section_image.dart';
import 'package:gphil/components/score/score_movements.dart';
import 'package:gphil/components/score/score_sections.dart';
import 'package:gphil/components/score/section_tempos.dart';
import 'package:gphil/components/score/show_prompt.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

final persistentController = PersistentDataController();

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<ScoreProvider>(context, listen: false).getScore(),
      builder: (context, snapshot) {
        return Consumer<ScoreProvider>(builder: (context, provider, child) {
          final p = Provider.of<PlaylistProvider>(context);
          final n = Provider.of<NavigationProvider>(context);
          if (provider.currentScore == null) {
            return Center(child: Text(provider.error));
          } else {
            return Stack(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScoreNavigation(s: provider, n: n, p: p),

                        const SizedBox(height: separatorSm),

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
                                          .titleLarge),
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
                                  Text('S E C T I O N S',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge),
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
                              child: ScoreMovements(
                                  movements: provider.currentMovements),
                            ),
                            const SizedBox(width: separatorLg),

                            //SECTIONS
                            Expanded(
                                flex: 3,
                                child: ScoreSections(
                                  sections: provider.currentSections,
                                ))
                          ],
                        ),

                        const SizedBox(height: separatorXs),
                      ]),

                  //SECTION IMAGE
                  SizedBox(
                    // height: 560,
                    child: Align(
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text('Section starts at:',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: separatorXs),
                            SectionImage(imageFile: provider.sectionImageFile),
                            const SizedBox(height: 18),
                            SectionTempos(section: provider.currentSection),
                          ],
                        ),
                      ),
                    ),
                  ),
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
