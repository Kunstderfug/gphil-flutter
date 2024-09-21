import 'package:flutter/material.dart';
import 'package:gphil/components/library/recent_library_item.dart';
import 'package:provider/provider.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/theme/constants.dart';

class RecentLibraryItems extends StatelessWidget {
  const RecentLibraryItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        final recentItems =
            libraryProvider.recentlyAccessedItems.take(5).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Recently Viewed Scores',
                    style: TextStyle(
                        fontSize: fontSizeMd, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: separatorSm),
                  if (recentItems.isEmpty)
                    const Text('No recent items')
                  else
                    SizedBox(
                      height: 60, // Adjust this value as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentItems.length,
                        itemBuilder: (context, index) {
                          final item = recentItems[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: separatorMd),
                            child: RecentLibraryitem(item: item),
                          );
                        },
                      ),
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
