import 'package:flutter/material.dart';
import 'package:gphil/components/library/library_composer.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/theme/constants.dart';

class LibrarySection extends StatelessWidget {
  const LibrarySection({super.key, required this.l});

  final LibraryProvider l;

  int gridCount(double pixels) {
    return ((pixels - 100) / 460).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount(MediaQuery.sizeOf(context).width),
                  crossAxisSpacing: separatorMd,
                  mainAxisSpacing: separatorLg,
                  childAspectRatio: 7 / 5,
                ),
                itemCount: l.indexedLibrary.composers.length,
                itemBuilder: (context, index) {
                  return LibraryComposer(
                    composerName: l.indexedLibrary.composers[index].name,
                    composerScores: l.indexedLibrary.composers[index].scores,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
