import 'package:flutter/material.dart';
import 'package:gphil/library_item.dart';

class Score extends StatelessWidget {
  final LibraryItem item;
  const Score({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(item.shortTitle),
            Text(item.composer),
          ],
        ),
      ),
    );
  }
}
