// import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionImage extends StatelessWidget {
  final File? imageFile;
  const SectionImage({super.key, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScoreProvider, ThemeProvider>(
        builder: (context, scoreProvider, themeProvider, child) {
      if (scoreProvider.currentSection.sectionImage == null) {
        return SizedBox(
          width: 600,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.grey[300]
                    : Colors.grey[100],
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              child: Center(
                child: Text(
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 32),
                  'No image yet',
                ),
              ),
            ),
          ),
        );
      } else {
        return Column(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: imageWidth(context)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[300]
                        : Colors.grey[100],
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                  ),
                  child: imageFile != null
                      ? Image.file(
                          imageFile!,
                          filterQuality: FilterQuality.medium,
                          isAntiAlias: true,
                          fit: BoxFit.contain,
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).highlightColor,
                            strokeWidth: 2,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      }
    });
  }
}
