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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          composerName.toUpperCase(),
          style: TextStyles().textMd,
        ),
        const SizedBox(height: separatorSm),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final LibraryItem score in composerScores)
                  LibraryItemCard(
                    libraryItem: score,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
