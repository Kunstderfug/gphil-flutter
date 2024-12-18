import 'package:flutter/material.dart';
import 'package:gphil/components/library/library_item.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/theme/constants.dart';

class LibraryComposer extends StatelessWidget {
  final String composerName;
  final List<LibraryItem> composerScores;
  const LibraryComposer(
      {super.key, required this.composerName, required this.composerScores});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: separatorXs,
        children: [
          Text(
            '${composerName.toUpperCase()} ${composerScores.length != 1 ? '(${composerScores.length})' : ''}',
            softWrap: true,
            overflow: TextOverflow.fade,
            style: TextStyles().textLg,
          ),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.0,
              children: [
                for (final LibraryItem score in composerScores)
                  LibraryItemCard(
                    libraryItem: score,
                  ),
              ]),
        ],
      ),
    );
  }
}
