// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gphil/providers/score_provider.dart';
import 'package:gphil/services/sanity_service.dart';
import 'package:gphil/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class ScoreImage extends StatelessWidget {
  const ScoreImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScoreProvider>(builder: (context, scoreProvider, child) {
      if (scoreProvider.currentSection!.sectionImage == null) {
        return const Center(child: Text('No image found'));
      } else {
        return SizedBox(
            // height: 400,
            width: 900,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                return Container(
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.grey[300]
                          : Colors.grey[100],
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      boxShadow: [
                        //darker shadow on bottom right
                        BoxShadow(
                          color: Colors.grey.shade500,
                          blurRadius: 15,
                          offset:
                              const Offset(4, 4), // changes position of shadow
                        ),

                        //lighter shadow on bottom left
                        BoxShadow(
                          color: Theme.of(context).colorScheme.background,
                          blurRadius: 15,
                          offset: const Offset(
                              -4, -4), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Image.network(
                      queryImage(scoreProvider
                              .currentSection!.sectionImage!.asset.ref)
                          .toString(),
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      // color: Theme.of(context).colorScheme.inversePrimary,
                      // colorBlendMode: BlendMode.darken,
                    ));
              }),
            ));
      }
    });
  }
}

String queryImage(asset) {
  final sanity = SanityService();
  return sanity.queryImageUrl(asset);
}
