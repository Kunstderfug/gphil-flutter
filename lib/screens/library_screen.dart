import 'package:flutter/material.dart';
import 'package:gphil/components/library/score_index.dart';
import 'package:gphil/components/library/library_item.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  int gridCount(double pixels) {
    return (pixels / 700).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Flexible(
                    flex: 3,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            gridCount(MediaQuery.of(context).size.width),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 3 / 1,
                      ),
                      itemCount: provider.library.length,
                      itemBuilder: (context, index) {
                        return LibraryItemCard(
                            scoreCard: provider.library[index]);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: Center(
                      child: Container(
                        height: 3,
                        color: Theme.of(context).highlightColor,
                      ),
                    ),
                  ),

                  //LIbraryIndex

                  Flexible(
                    flex: 2,
                    child: ScoreIndex(library: provider.indexedLibrary),
                  ),
                ],
              ),
      );
    });
  }
}
