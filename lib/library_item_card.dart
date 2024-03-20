import 'package:flutter/material.dart';
import 'package:gphil/library_item.dart';

class LibraryItemCard extends StatelessWidget {
  final LibraryItem item;
  const LibraryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(item.shortTitle),
          Text(item.composer),
        ],
      ),
    );
  }
}
