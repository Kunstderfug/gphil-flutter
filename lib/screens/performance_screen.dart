import 'package:flutter/cupertino.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/image_progress.dart';
import 'package:gphil/components/performance/movements_area.dart';
import 'package:gphil/components/performance/player_area.dart';
import 'package:gphil/components/performance/playlist_empty.dart';
import 'package:gphil/components/performance/sections_area.dart';
import 'package:gphil/components/player/player_header.dart';
import 'package:gphil/components/score/section_image.dart';
import 'package:gphil/components/score/section_tempos.dart';
import 'package:gphil/models/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    Widget image = Stack(alignment: Alignment.topLeft, children: [
      SectionImage(imageFile: p.currentSectionImage, width: 250),
      // if (p.isPlaying)
      const Positioned(
        top: sizeXs,
        child: ImageProgress(),
      )
    ]);

    Widget autoSwitch = Align(
      alignment: Alignment.topRight,
      child: Opacity(
        opacity: p.currentSection?.autoContinueMarker == null ? 0.5 : 1,
        child: Wrap(
            spacing: 8,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Section Auto Continue',
                style: TextStyles().textSm,
              ),
              Transform.scale(
                scale: isTablet(context) ? 1 : 0.6,
                child: CupertinoSwitch(
                  activeColor: highlightColor,
                  value: p.currentSection?.autoContinue != null
                      ? p.currentSection!.autoContinue!
                      : false,
                  onChanged: (value) async {
                    if (p.currentSection!.autoContinueMarker != null) {
                      p.setCurrentSectionAutoContinue();
                    }
                  },
                ),
              ),
            ]),
      ),
    );

    Widget laptopBody = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxLaptopWidth),
        child: Column(
          children: [
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
                      const MovementsArea(isTablet: true),
                      const SeparatorLine(height: 48),
                      // const SizedBox(
                      //   height: separatorXs,
                      // ),
                      SizedBox(height: separatorLg, child: autoSwitch),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 50),
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
                      height: separatorLg,
                    ),
                    Text(
                      'Some important stuff \n will be here in the future\nmaybe',
                      textAlign: TextAlign.center,
                      style: TextStyles().textLg,
                    ),
                  ],
                )),
              ],
            ),
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
      const MovementsArea(isTablet: true),
      SizedBox(
        height: separatorMd,
        child: autoSwitch,
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
      return p.isLoading ? const FileLoading() : layout;
    }
  }
}
