import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/all_sections_tempo_switch.dart';
import 'package:gphil/components/performance/floating_info.dart';
import 'package:gphil/components/performance/global_mixer.dart';
import 'package:gphil/components/performance/image_progress.dart';
import 'package:gphil/components/performance/layers_error.dart';
import 'package:gphil/components/performance/mixer_info.dart';
import 'package:gphil/components/performance/movements_area.dart';
import 'package:gphil/components/performance/one_pedal_mode_switch.dart';
import 'package:gphil/components/performance/player_area.dart';
import 'package:gphil/components/performance/playlist_empty.dart';
import 'package:gphil/components/performance/section_management.dart';
import 'package:gphil/components/performance/sections_area.dart';
import 'package:gphil/components/player/player_header.dart';
import 'package:gphil/components/score/section_image.dart';
import 'package:gphil/components/score/section_tempos.dart';
import 'package:gphil/components/social_button.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class PerformanceScreen extends StatelessWidget {
  final double imageSize = 600;
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    final n = Provider.of<NavigationProvider>(context);

    Widget image = Stack(alignment: Alignment.topLeft, children: [
      SectionImage(imageFile: p.currentSectionImage, width: imageSize),
      // if (p.isPlaying)
      Positioned(
        top: sizeXs,
        child: ImageProgress(windowSize: imageSize),
      )
    ]);

    List<Widget> mainArea = [
      PlayerHeader(sectionName: p.currentSection?.name ?? ''),
      const SizedBox(
        height: separatorSm,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 58,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                                p.currentSection!.name.replaceAll('_', ' '),
                                style: TextStyles().textXl),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              p.currentSection!.autoContinueMarker != null
                                  ? 'Auto-Continue'
                                  : '',
                              style: TextStyle(
                                  fontSize: fontSizeLg,
                                  fontWeight: FontWeight.bold,
                                  color: p.currentSection!.autoContinue != false
                                      ? greenColor
                                      : Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ]),
                ),
                const SeparatorLine(height: 46),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OnePedalMode(p: p),
                    if (n.isPerformanceScreen && p.areAllTempoRangesEqual)
                      AllSectionsTempoSwitch(p: p),
                  ],
                ),
                const SizedBox(
                  height: separatorMd,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: paddingMd),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // const SectionsArea(),
                      const SizedBox(
                        height: separatorLg,
                        width: separatorMd,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              if (p.currentSection != null)
                                SectionTempos(section: p.currentSection!),
                              const SizedBox(height: paddingXl),
                              SizedBox(
                                width: imageWidth(context),
                                child: SectionManagement(p: p),
                              ),
                              const SizedBox(
                                height: separatorSm,
                              ),
                              image,
                              const SizedBox(
                                height: separatorSm,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Opacity(
                    opacity: p.appState == AppState.loading ? 0.5 : 1,
                    child: const PlayerArea()),
                const SizedBox(
                  height: separatorMd,
                ),
                GlobalMixer(p: p),
              ],
            ),
          ),
        ],
      ),
    ];

    Widget laptopBody = ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: maxLaptopWidth,
            minHeight: MediaQuery.sizeOf(context).height - 140),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Column(children: mainArea),
            if (kDebugMode) FloatingWindow(child: MixerInfo(p: p)),
            footer,
            //Error message
            if (p.error.isNotEmpty)
              const Positioned(
                top: 600,
                right: 60,
                child: LayersError(),
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
      const MovementsArea(),
      const SizedBox(
        height: separatorXs,
      ),
      SeparatorLine(height: separatorSm),
      const SizedBox(
        height: separatorXs,
      ),
      const SectionsArea(),
      const SizedBox(
        height: separatorXs,
      ),
      if (p.currentSection != null) SectionTempos(section: p.currentSection!),
      const SizedBox(
        height: separatorXs,
      ),
      if (p.currentSection?.sectionImage != null) image,
      const SizedBox(
        height: separatorLg,
      ),
      footer
    ]);

    Widget layout = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth >= 1200) {
        return Center(child: laptopBody);
      } else {
        return tabletBody;
      }
    });

    if (p.playlist.isEmpty) {
      return const PlaylistIsEmpty();
    } else {
      return p.filesDownloading
          ? LoadingFiles(
              filesLoaded: p.filesDownloaded, filesLength: p.playlist.length)
          : p.isLoading
              ? LoadingFiles(
                  filesLoaded: p.filesLoaded, filesLength: p.playlist.length)
              : layout;
    }
  }
}

List<Widget> socialButtons = [
  SocialButton(
      label: 'Say Thank You',
      icon: Icons.paypal,
      url: 'https://www.paypal.com/ncp/payment/3KH4DFTTQMXYJ',
      iconColor: Colors.red.shade900,
      borderColor: highlightColor),
  SocialButton(
      label: 'Report a bug',
      icon: Icons.bug_report,
      url: 'https://discord.gg/DMDvB6NFJu',
      iconColor: Colors.red.shade900,
      borderColor: Colors.red.shade900),
];

Widget footer = Positioned(
  bottom: 0,
  left: 0,
  child: SizedBox(
    width: 360,
    height: 30,
    child: Wrap(
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      spacing: sizeXs,
      runSpacing: sizeXs,
      crossAxisAlignment: WrapCrossAlignment.start,
      direction: Axis.horizontal,
      children: socialButtons,
    ),
  ),
);
