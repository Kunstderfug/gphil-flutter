import 'package:flutter/material.dart';
import 'package:gphil/components/library/library_search.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:provider/provider.dart';

class GlobalSearchDialog extends StatelessWidget {
  const GlobalSearchDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = Provider.of<LibraryProvider>(context, listen: false);

    return LibrarySearch(
      l: l,
      closeParentDialog: true,
      isGlobalSearch: true,
    );
  }
}
