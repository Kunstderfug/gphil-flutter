import 'package:flutter/material.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:provider/provider.dart';

class RecentLibraryitem extends StatelessWidget {
  const RecentLibraryitem({super.key, required this.item});
  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final s = Provider.of<ScoreProvider>(context, listen: false);
    final l = Provider.of<LibraryProvider>(context, listen: false);
    return TextButton(
      onPressed: () async {
        s.setCurrentScoreIdAndRevision(item.id, item.rev);
        l.setScoreId(item.id);
        await s.getScore(item.id);
        n.setNavigationIndex(2);
        l.addToRecentlyAccessed(item);
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(8),
        backgroundColor: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item.shortTitle,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              )), // Larger font size for title
          Text(item.composer,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              )), // Smaller font size for composer
          // Smaller font size for composer
        ],
      ),
    );
  }
}
