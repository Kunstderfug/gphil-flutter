import 'package:flutter/material.dart';
import 'package:gphil/providers/library_provider.dart';

class ScoreIndex extends StatelessWidget {
  final LibraryIndex library;
  const ScoreIndex({super.key, required this.library});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3 / 1,
      ),
      itemCount: library.composers.length,
      itemBuilder: (context, index) {
        return Text(library.composers[index].name);
      },
    );
  }
}
