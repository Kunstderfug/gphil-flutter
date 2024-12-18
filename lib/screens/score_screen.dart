import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gphil/components/library/score_navigation.dart';
import 'package:gphil/components/score/section_image.dart';
import 'package:gphil/components/score/score_movements.dart';
import 'package:gphil/components/score/score_sections.dart';
import 'package:gphil/components/score/show_prompt.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/playlist_classes.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';
// import 'package:gphil/providers/global_providers.dart';

final pc = PersistentDataController();

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

    // Calculate available height
    final double availableHeight = MediaQuery.of(context).size.height -
        (isTablet(context) ? appBarSizeDesktop : appBarSize);

    return s.currentScore == null
        ? const Center(child: Text('There was a problem loading the score'))
        : SizedBox(
            height:
                availableHeight - (isTablet(context) ? appBarSizeDesktop : 0),
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RepaintBoundary(child: ScoreNavigation()),
                      SizedBox(height: separatorXs),
                      MvtSectionsHead(),
                      MvtSections(),
                      // SizedBox(height: separatorXl),
                    ],
                  ),
                  if (p.showPrompt) const ShowPrompt(),
                ],
              ),
            ),
          );
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
    final p = Provider.of<PlaylistProvider>(context);

    if (isTablet(context)) {
      // Tablet layout
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ScoreMovements(movements: s.currentMovements),
              ),
              const SizedBox(width: separatorLg),
              Expanded(
                flex: 3,
                child: ScoreSections(sections: s.currentSections),
              ),
            ],
          ),
          const SizedBox(height: separatorSm),
          // Section image and controls centered below
          Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 700), // Adjust as needed
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Section starts at:',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 20),
                    child: SectionImage(imageFile: s.sectionImageFile),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'Available tempos: ${s.currentSection.tempoRange.first} - ${s.currentSection.tempoRange.last} bpm, with a step of ${s.currentSection.step}',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                      ),
                      IconButton(
                          icon: p.isPlaying
                              ? const Icon(Icons.stop)
                              : const Icon(Icons.play_arrow),
                          onPressed: () async {
                            p.isPlaying
                                ? await p.stop()
                                : await p.playSection(s.currentSection);
                          },
                          iconSize: sizeXl,
                          padding: const EdgeInsets.all(paddingMd),
                          tooltip: "Play section"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Desktop layout (original layout)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: ScoreMovements(movements: s.currentMovements),
        ),
        const SizedBox(width: separatorLg),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              ScoreSections(sections: s.currentSections),
              SizedBox(
                child: Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: separatorMd),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Section starts at:',
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 20),
                          child: SectionImage(imageFile: s.sectionImageFile),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  'Available tempos: ${s.currentSection.tempoRange.first} - ${s.currentSection.tempoRange.last} bpm, with a step of ${s.currentSection.step}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ),
                            IconButton(
                                icon: p.isPlaying
                                    ? const Icon(Icons.stop)
                                    : const Icon(Icons.play_arrow),
                                onPressed: () async {
                                  p.isPlaying
                                      ? await p.stop()
                                      : await p.playSection(s.currentSection);
                                },
                                iconSize: sizeXl,
                                padding: const EdgeInsets.all(paddingMd),
                                tooltip: "Play section"),
                          ],
                        ),
                        if (p.error.isNotEmpty && kDebugMode)
                          Text('error: ${p.error}'),
                        if (p.playerAudioSources.isNotEmpty)
                          for (PlayerAudioSource source in p.playerAudioSources)
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                      '${source.audioSource}: ${source.sectionKey}'),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
