import 'package:flutter/material.dart';
import 'package:gphil/components/library/score_navigation.dart';
import 'package:gphil/components/score/section_image.dart';
import 'package:gphil/components/score/score_movements.dart';
import 'package:gphil/components/score/score_sections.dart';
import 'package:gphil/components/score/section_tempos.dart';
import 'package:gphil/components/score/show_prompt.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

final persistentController = PersistentDataController();

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  @override
  void initState() {
    super.initState();
    final l = Provider.of<LibraryProvider>(context, listen: false);
    final s = Provider.of<ScoreProvider>(context, listen: false);
    s.getScore(l.currentScoreId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<ScoreProvider>(context);
    final p = Provider.of<PlaylistProvider>(context);
    return s.currentScore == null
        ? const Center(child: Text('There was a problem loading the score'))
        : Stack(children: [
            const Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  RepaintBoundary(child: ScoreNavigation()),
                  SizedBox(height: separatorXs),
                  MvtSectionsHead(),
                  MvtSections(),
                  SizedBox(height: separatorXl),
                ]),
              ],
            ),
            if (p.showPrompt) const ShowPrompt(),
          ]);
  }
}

class MvtSectionsHead extends StatelessWidget {
  const MvtSectionsHead({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<ScoreProvider>(context);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('M O V E M E N T S',
                  style: Theme.of(context).textTheme.titleMedium),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('S E C T I O N S',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (!s.scoreIsUptoDate)
                    Text(s.isLoading ? 'Updating...' : 'Update available',
                        style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SeparatorLine(),
            ],
          ),
        ),
      ],
    );
  }
}

class MvtSections extends StatelessWidget {
  const MvtSections({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<ScoreProvider>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ScoreMovements(movements: s.currentMovements),
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
                          const SizedBox(height: separatorMd),
                          Text('Section starts at:',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: separatorXs),
                          SectionImage(
                              imageFile: s.sectionImageFile, width: 250),
                          const SizedBox(height: separatorXs),
                          SectionTempos(section: s.currentSection),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ))
      ],
    );
  }
}
