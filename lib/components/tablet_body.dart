import 'package:flutter/material.dart';
import 'package:gphil/components/performance/player_area.dart';
import 'package:gphil/components/performance/movements_area.dart';
import 'package:gphil/components/player/player_header.dart';
import 'package:gphil/components/score/section_tempos.dart';
import 'package:gphil/providers/playlist_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class TabletBody extends StatelessWidget {
  const TabletBody({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<PlaylistProvider>(context);
    return Column(children: [
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
      // const SectionsArea(),
      const SizedBox(
        height: separatorXs,
      ),
      if (p.currentSection != null) SectionTempos(section: p.currentSection!),
      const SizedBox(
        height: separatorXs,
      ),
      const SizedBox(
        height: separatorLg,
      ),
    ]);
  }
}
