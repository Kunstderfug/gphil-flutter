// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/providers/navigation_provider.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:provider/provider.dart';

class LibrarySearch extends StatefulWidget {
  final LibraryProvider l;
  final bool closeParentDialog;
  final bool isGlobalSearch;

  const LibrarySearch({
    super.key,
    required this.l,
    this.closeParentDialog = false,
    this.isGlobalSearch = false,
  });

  @override
  State<LibrarySearch> createState() => _LibrarySearchState();
}

class _LibrarySearchState extends State<LibrarySearch> {
  late final SearchController searchController;

  @override
  void initState() {
    super.initState();
    searchController = SearchController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isGlobalSearch) {
        searchController.openView();
      }
    });
  }

  @override
  void dispose() {
    // searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = Provider.of<NavigationProvider>(context, listen: false);
    final s = Provider.of<ScoreProvider>(context, listen: false);
    final l = Provider.of<LibraryProvider>(context, listen: false);

    Future<void> setScore(LibraryItem libraryItem) async {
      // Then handle the score selection
      s.setCurrentScoreIdAndRevision(libraryItem.id, libraryItem.rev);
      l.setScoreId(libraryItem.id);
      await s.getScore(libraryItem.id);
      n.setScoreScreen();
      l.addToRecentlyAccessed(libraryItem);
    }

    List<TextSpan> buildHighlightedSpans(
        String text, List<(int, int)> matches) {
      final List<TextSpan> spans = [];
      int currentIndex = 0;

      for (final match in matches) {
        // Add non-matching text before the match
        if (currentIndex < match.$1) {
          spans.add(TextSpan(
            text: text.substring(currentIndex, match.$1),
          ));
        }

        // Add matching text with bold style
        spans.add(TextSpan(
          text: text.substring(match.$1, match.$2),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ));

        currentIndex = match.$2;
      }

      // Add remaining text after last match
      if (currentIndex < text.length) {
        spans.add(TextSpan(
          text: text.substring(currentIndex),
        ));
      }

      return spans;
    }

    List<(int, int)> getMatchedRanges(String text, String query) {
      final List<(int, int)> matches = [];
      int index = 0;
      while (true) {
        index = text.indexOf(query, index);
        if (index == -1) break;
        matches.add((index, index + query.length));
        index += query.length;
      }
      return matches;
    }

    void closeSearchAndDialog(BuildContext context) {
      searchController.closeView('');
      if (widget.closeParentDialog) {
        Navigator.of(context).pop();
      }
    }

    Widget searchBar = SearchAnchor.bar(
      searchController: searchController,
      barHintText: 'Search scores...',
      viewHintText: 'Type to search scores...',
      barLeading: const Icon(Icons.search),
      viewLeading: const Icon(Icons.search),
      viewHeaderTextStyle: const TextStyle(
        // fontSize: 16,
        color: Colors.grey,
      ),
      viewTrailing: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => closeSearchAndDialog(context),
        ),
      ],
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        final query = controller.text.toLowerCase();
        if (query.isEmpty) {
          return [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Type to search...'),
              ),
            ),
          ];
        }

        // Filter scores
        final filteredScores = l.library.where((LibraryItem score) {
          final title = score.shortTitle.toLowerCase();
          final composer = score.composer.toLowerCase();
          return title.contains(query) || composer.contains(query);
        }).toList();

        // Show "No results found" message if filteredScores is empty
        if (filteredScores.isEmpty) {
          return [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No results found for "$query"',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        }

        // Group by composer
        final groupedScores = <String, List<LibraryItem>>{};
        for (var score in filteredScores) {
          groupedScores.putIfAbsent(score.composer, () => []);
          groupedScores[score.composer]!.add(score);
        }

        // Sort composers alphabetically
        final sortedComposers = groupedScores.keys.toList()..sort();

        return sortedComposers.expand((composer) {
          final scores = groupedScores[composer]!;
          return [
            // Composer header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              color: Colors.black87,
              child: Text(
                composer,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            // Score items
            ...scores.map((score) {
              final titleMatches =
                  getMatchedRanges(score.shortTitle.toLowerCase(), query);
              final composerMatches =
                  getMatchedRanges(score.composer.toLowerCase(), query);

              return ListTile(
                title: RichText(
                  text: TextSpan(
                    children:
                        buildHighlightedSpans(score.shortTitle, titleMatches),
                    style:
                        const TextStyle(color: Colors.white), // Base text style
                  ),
                ),
                subtitle: RichText(
                  text: TextSpan(
                    children:
                        buildHighlightedSpans(score.composer, composerMatches),
                    style: const TextStyle(
                        color: Colors.grey), // Subtitle text style
                  ),
                ),
                onTap: () async {
                  await setScore(score);
                  closeSearchAndDialog(context);
                },
              );
            }),
          ];
        }).toList();
      },
    );

    return !widget.isGlobalSearch
        ? searchBar
        : Dialog(
            child: SizedBox(
            width: 600,
            child: searchBar,
          ));
  }
}
