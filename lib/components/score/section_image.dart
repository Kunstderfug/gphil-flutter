// import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gphil/providers/score_provider.dart';
// import 'package:gphil/providers/theme_provider.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/sanity_service.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionImage extends StatelessWidget {
  final File? imageFile;
  final double width;
  const SectionImage({super.key, this.imageFile, required this.width});

  @override
  Widget build(BuildContext context) {
    final a = Provider.of<AppConnection>(context);

    return Consumer<ScoreProvider>(builder: (context, s, child) {
      if (s.currentSection.sectionImage == null) {
        return SizedBox(
          width: width,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              // constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRad().bRadiusMd),
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
        return kIsWeb
            ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRad().bRadiusMd,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: SanityService()
                        .getImageUrl(s.currentSection.sectionImage!.asset.ref),
                    placeholder: (context, url) => const Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fadeInDuration: const Duration(milliseconds: 200),
                    fadeOutDuration: const Duration(milliseconds: 200),
                  ),
                ),
              )
            : Container(
                // constraints: BoxConstraints(maxWidth: imageWidth(context)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
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
              );
      }
    });
  }
}
