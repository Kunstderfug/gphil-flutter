import 'package:flutter/material.dart';
import 'package:gphil/components/performance/global_mixer.dart';
import 'package:gphil/components/performance/image_progress.dart';
import 'package:gphil/components/performance/section_management.dart';
import 'package:gphil/components/score/section_image.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionManagementMixer extends StatelessWidget {
  final double separatorWidth;

  const SectionManagementMixer({super.key, required this.separatorWidth});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);

    Widget image = Stack(alignment: Alignment.topLeft, children: [
      SectionImage(imageFile: p.currentSectionImage),
      // if (p.isPlaying)
      Positioned(
        top: sizeXs,
        child: ImageProgress(),
      )
    ]);

    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //RIGHT SIDE, SECTION MANAGEMENT
          Expanded(
            child: Column(
              children: [
                SectionManagement(p: p),
                //SECTION IMAGE
                if (p.currentSection?.sectionImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: paddingXl),
                    child: ImageProgress(),
                  ),
              ],
            ),
          ),

          //Separator
          SizedBox(
            width: separatorWidth,
          ),

          //RIGHT SIDE, PLAYLIST CONTROLS
          Expanded(
            child: Column(
              children: [
                SizedBox(height: sizeXs),
                GlobalMixer(p: p),
              ],
            ),
          )
        ]);
  }
}
