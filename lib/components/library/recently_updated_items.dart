import 'package:flutter/material.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class RecentlyUpdatedItems extends StatelessWidget {
  const RecentlyUpdatedItems({super.key, required this.l});

  final LibraryProvider l;

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context);
    final s = Provider.of<ScoreProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('R E C E N T L Y    U P D A T E D',
            style: TextStyle(fontSize: fontSizeLg)),
        const SizedBox(height: separatorSm),
        SizedBox(
          height: 180,
          child: ListView.builder(
            itemCount: l.recentlyUpdatedItems.length,
            itemBuilder: (context, index) {
              final item = l.recentlyUpdatedItems[index];
              return Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      foregroundColor: Colors.white,
                    ).copyWith(
                      foregroundColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            return Colors.grey[300]!;
                          }
                          return Colors.white;
                        },
                      ),
                    ),
                    onPressed: () async {
                      s.setCurrentScoreIdAndRevision(item.id, item.rev);
                      l.setScoreId(item.id);
                      await s.getScore(item.id);
                      n.setNavigationIndex(2);
                      l.addToRecentlyAccessed(item);
                    },
                    child: Text(
                      '${item.composer} - ${item.shortTitle}',
                      style: const TextStyle(
                        fontSize: fontSizeMd,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
