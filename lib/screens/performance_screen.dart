import 'package:flutter/material.dart';
import 'package:gphil/components/file_loading.dart';
import 'package:gphil/components/performance/image_progress.dart';
import 'package:gphil/components/performance/movements_area.dart';
import 'package:gphil/components/performance/player_area.dart';
import 'package:gphil/components/performance/playlist_empty.dart';
import 'package:gphil/components/performance/sections_area.dart';
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

    Widget body = Column(children: [
      const PlayerArea(),
      const SizedBox(
        height: separatorXs,
      ),
      const MovementsArea(),
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
      if (p.currentSection?.sectionImage != null)
        Stack(alignment: Alignment.topLeft, children: [
          SectionImage(imageFile: p.currentSectionImage),
          // if (p.isPlaying)
          const Positioned(
            top: 10,
            child: ImageProgress(),
          )
        ]),
    ]);

    if (p.playlist.isEmpty) {
      return const PlaylistIsEmpty();
    } else {
      return p.isLoading ? const FileLoading() : body;
    }
  }
}
