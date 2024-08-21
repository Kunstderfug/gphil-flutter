import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/global_mixer.dart';
import 'package:gphil/components/performance/image_progress.dart';
import 'package:gphil/components/performance/movements_area.dart';
import 'package:gphil/components/performance/one_pedal_mode_switch.dart';
// import 'package:gphil/components/performance/pdf_viewer.dart';
// import 'package:gphil/components/performance/pdf_viewer.dart';
import 'package:gphil/components/performance/player_area.dart';
import 'package:gphil/components/performance/playlist_empty.dart';
import 'package:gphil/components/performance/section_auto_continue_switch.dart';
import 'package:gphil/components/performance/sections_area.dart';
import 'package:gphil/components/performance/switch.dart';
import 'package:gphil/components/player/player_header.dart';
import 'package:gphil/components/score/section_image.dart';
import 'package:gphil/components/score/section_tempos.dart';
import 'package:gphil/components/social_button.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceScreen extends StatelessWidget {
  final double windowSize = 600;
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    Widget image = Stack(alignment: Alignment.topLeft, children: [
      SectionImage(imageFile: p.currentSectionImage, width: windowSize),
      // if (p.isPlaying)
      Positioned(
        top: sizeXs,
        child: ImageProgress(windowSize: windowSize),
      )
    ]);

    List<Widget> mainArea = [
      PlayerHeader(sectionName: p.currentSection?.name ?? ''),
      const SizedBox(
        height: separatorLg,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                const MovementsArea(),
                const SeparatorLine(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OnePedalMode(p: p),
                    SectionAutoContinueSwitch(p: p),
                  ],
                ),
                const SizedBox(
                  height: separatorMd,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 130),
                  child: const SectionsArea(),
                ),
                const SizedBox(
                  height: separatorSm,
                ),
                if (p.currentSection != null)
                  SectionTempos(section: p.currentSection!),
                const SizedBox(
                  height: separatorSm,
                ),
                if (p.currentSection?.sectionImage != null) image
              ],
            ),
          ),
          const SizedBox(
            width: separatorXl,
          ),
          Expanded(
            child: Column(
              children: [
                const PlayerArea(),
                const SizedBox(
                  height: separatorMd,
                ),
                GlobalMixer(p: p),
              ],
            ),
          ),
        ],
      )
    ];

    Widget laptopBody = ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: maxLaptopWidth,
            minHeight: MediaQuery.sizeOf(context).height - 120),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: SizedBox(
                width: 180,
                height: 40,
                child: SocialButton(
                    label: 'Report a bug',
                    icon: Icons.bug_report,
                    url: 'https://discord.gg/DMDvB6NFJu',
                    iconColor: Colors.red.shade900,
                    borderColor: Colors.red.shade900),
              ),
            ),
            Column(
              children: [
                ...mainArea,
              ],
            ),
            // const PdfViewer(),
          ],
        ));

    Widget tabletBody = Column(children: [
      PlayerHeader(sectionName: p.currentSection?.name ?? ''),
      const SizedBox(
        height: separatorXs,
      ),
      const PlayerArea(),
      const SizedBox(
        height: separatorXs,
      ),
      Text(p.currentSection?.sectionIndex.toString() ?? ''),
      const MovementsArea(),
      SizedBox(
        height: separatorMd,
        child: AutoSwitch(
          p: p,
          onToggle: (value) => p.setCurrentSectionAutoContinue(),
          label: 'Section auto-continue',
          value: p.currentSection?.autoContinue != null
              ? p.currentSection!.autoContinue!
              : false,
          opacity: p.currentSection?.autoContinueMarker != null ? 1 : 0.4,
        ),
      ),
      const SectionsArea(),
      const SizedBox(
        height: separatorXs,
      ),
      if (p.currentSection != null) SectionTempos(section: p.currentSection!),
      const SizedBox(
        height: separatorXs,
      ),
      if (p.currentSection?.sectionImage != null) image
    ]);

    Widget layout = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth >= 1200) {
        return laptopBody;
      } else {
        return tabletBody;
      }
    });

    if (p.playlist.isEmpty) {
      return const PlaylistIsEmpty();
    } else {
      return p.isLoading
          ? LoadingLayerFiles(
              filesLoaded: p.filesLoaded, filesLength: p.playlist.length)
          : layout;
    }
  }
}
