// import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionImage extends StatelessWidget {
  final File? imageFile;
  final double width;
  const SectionImage({super.key, this.imageFile, required this.width});

  //s scoreProvider
  //t themeProvider

  @override
  Widget build(BuildContext context) {
    final a = Provider.of<AppConnection>(context);

    return Consumer2<ScoreProvider, ThemeProvider>(
        builder: (context, s, t, child) {
      if (s.currentSection.sectionImage == null) {
        return SizedBox(
          width: width,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                  color: t.isDarkMode ? Colors.grey[300] : Colors.grey[100],
                  borderRadius: BorderRad().bRadiusMd),
              child: Center(
                child: Text(
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: fontSizeMd),
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
                    color: t.isDarkMode ? Colors.grey[300] : Colors.grey[100],
                    borderRadius: BorderRad().bRadiusMd,
                  ),
                  child: imageFile != null
                      ? Image.file(
                          imageFile!,
                          filterQuality: FilterQuality.medium,
                          isAntiAlias: true,
                          fit: BoxFit.contain,
                        )
                      : Center(
                          child: a.appState == AppState.offline
                              ? const Text(
                                  'Image is not available, app is offline',
                                  style: TextStyle(color: Colors.black54),
                                )
                              : CircularProgressIndicator(
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
